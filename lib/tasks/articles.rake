# frozen_string_literal: true

USER_AGENT = 'LBCC library (libref@linnbenton.edu) Ruby 2.6'

require 'csv'
require 'sparql/client'

namespace :findit do
  namespace :data do
    namespace :index do
      task sample_articles: :environment do
        index_holdings_from_kbart filename: Rails.root.join('spec/fixtures/files/kbart.txt')
        Rake::Task['findit:data:commit'].execute
      end
    end
  end
end

def index_holdings_from_kbart(filename:)
  puts "indexing #{filename}"
  CSV.read(filename, 'r', col_sep: "\t", headers: true, quote_char: "\x00",
                          encoding: 'utf-8').each_slice(10) do |periodicals|
    wikidata_periodicals, wikidata_articles = get_periodical_metadata_and_articles_from_wikidata periodicals
    crossref_articles = get_articles_from_crossref periodicals
    articles = deduplicate_articles wikidata: wikidata_articles, crossref: crossref_articles
    write_to_solr wikidata_periodicals
    write_to_solr articles
  end
end

def get_periodical_metadata_and_articles_from_wikidata(periodicals)
  periodical_data = []
  article_data = []
  select_periodicals_only(periodicals).each do |row|
    periodical = fetch_periodical_data_from_wikidata_by_issn(row) || fetch_periodical_data_from_wikidata_by_title(row)
    if periodical
      periodical_data.push periodical
      article_data.concat(fetch_article_data_from_wikidata(periodical[:id]))
    end
  end
  [periodical_data, article_data]
end

def extract_issn(row)
  good_issn = StdNum::ISSN.normalize(row['print_identifier']) || StdNum::ISSN.normalize(row['online_identifier'])

  # STDNum library strips out the hyphens, but wikidata uses hyphens.  Add them back in if it is a valid ISSN
  good_issn ? good_issn.insert(4, '-') : nil
end

def fetch_periodical_data_from_wikidata_by_issn(periodical)
  issn = extract_issn(periodical)
  return nil unless issn

  journal_metadata_query("?journal wdt:P236 \"#{issn}\" .", periodical['title_url'])
end

def fetch_periodical_data_from_wikidata_by_title(periodical)
  title = fix_trailing_article periodical['publication_title']
  return nil unless title

  uri = URI.parse "https://wikidata.reconci.link/en/api?queries=#{{ 'q1' => { 'query' => title,
                                                                              'limit' => 1 } }.to_json}"
  response = Net::HTTP.get uri
  results = JSON.parse(response)['q1']['result']
  return nil unless results.any?

  qid = results&.first['id']
  types = results&.first['type'].map { |type| type['name'] }
  return nil unless qid && any_valid_wikidata_types?(types)

  journal_metadata_query(
    "VALUES ?journal {wd:#{qid}}",
    periodical['title_url']
  )
end

def journal_metadata_query(where_clause, url_from_vendor)
  client = WikidataConnection.new
  query = <<~ENDQUERY
    SELECT ?journal ?journalLabel ?languageLabel ?journalDescription ?placeOfPublicationLabel ?formatLabel ?issn WHERE {
    #{where_clause}
    OPTIONAL{?journal wdt:P31 ?format} .
    OPTIONAL{?journal wdt:P495 ?placeOfPublication}  .
    OPTIONAL{?journal wdt:P407 ?language}  .
    OPTIONAL{?journal wdt:P236 ?issn}  .
    SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
    }
    LIMIT 1
  ENDQUERY
  periodical_rdf_to_solr(client.query(query), url_from_vendor)
end

def fetch_article_data_from_wikidata(journal_id)
  client = WikidataConnection.new
  query = <<~ENDQUERY
    CONSTRUCT {
      ?article wdt:P2093 ?authorStrings ;
        wdt:P2093 ?authorName ;
        wdt:P356 ?doi  ;
        wdt:P433 ?issue ;
        wdt:P1433 ?journal ;
        rdfs:label ?label ;
        wdt:P407 ?languageName ;
        wdt:P304 ?pages ;
        wdt:P304 ?pubDate ;
        wdt:P921 ?subjectName ;
        wdt:P1476 ?title ;
        wdt:P31 ?typeName ;
        wdt:P478 ?volume .
    }
    WHERE {
      ?article wdt:P1433 wd:#{journal_id} ;
        rdfs:label ?label ;
        wdt:P31 ?type.
      ?type rdfs:label ?typeName .
      OPTIONAL {?article wdt:P2093 ?authorStrings }
      OPTIONAL {?article wdt:P356 ?doi }
      OPTIONAL {?article wdt:P433 ?issue }
      OPTIONAL {?article wdt:P1433 ?journal }
      OPTIONAL {?article wdt:P304 ?pages }
      OPTIONAL {?article wdt:P304 ?pubDate }
      OPTIONAL {?article wdt:P478 ?volume }
      OPTIONAL {?article wdt:P50 ?author . ?author rdfs:label ?authorName }
      OPTIONAL {?article wdt:P1433 ?journal . ?journal rdfs:label ?journalName }
      OPTIONAL {?article wdt:P407 ?language . ?language rdfs:label ?languageName }
      OPTIONAL {?article wdt:P921 ?subject . ?subject rdfs:label ?subjectName }
      FILTER(lang(?authorName) = "en")
      FILTER(lang(?journalName) = "en")
      FILTER(lang(?languageName) = "en")
      FILTER(lang(?subjectName) = "en")
      FILTER(lang(?typeName) = "en")
    }
  ENDQUERY
  results = client.query query
  return [] unless results

  article_uris = results.pluck(:subject).uniq

  article_uris.map do |uri|
    matching_triples = results.select { |triple| triple[:subject] == uri }
    Article.new(wikidata: matching_triples).to_solr
  end
end

def get_articles_from_crossref(periodicals)
  # TODO: user agent
  # TODO: cache
  # TODO: follow all of the "NICE" rules for crossref api
  # TODO: if no link available, construct one using the link resolver

  documents = []
  select_periodicals_with_issns(periodicals).each do |issn|
    json = URI.parse("https://api.crossref.org/works?filter=issn:#{issn}&rows=1000").read
    result = JSON(json)
    result['message']['items'].each do |article|
      next unless article['title'] && article['link']

      document = Article.new crossref: article
      documents.push document.to_solr
    end
  end
  documents
end

def deduplicate_articles(wikidata:, crossref:)
  crossref.concat(wikidata.reject { |article| crossref.include? article })
end

def write_to_solr(contents)
  solr = RSolr.connect url: ENV['SOLR_URL']
  solr.add contents.compact
end

def periodical_rdf_to_solr(periodical, link)
  return nil unless periodical&.first

  {
    id: periodical.first[:journal].to_s.gsub('http://www.wikidata.org/entity/', ''),
    format: periodical.first[:formatLabel].to_s.capitalize || 'Periodical',
    place_of_publication_t: periodical.first[:placeOfPublicationLabel].to_s,
    abstract_t: periodical.first[:journalDescription].to_s,
    issn_t: periodical.first[:issn].to_s,
    title_t: periodical.first[:journalLabel].to_s.capitalize,
    title_display: periodical.first[:journalLabel].to_s.capitalize,
    language_facet: periodical.first[:languageLabel].to_s.capitalize,
    is_electronic_facet: 'Online',
    url_fulltext_display: ResourceLink.new(link).to_s
  }
end

def select_periodicals_only(periodicals)
  periodicals.select { |row| row && (row['coverage_depth'] == 'fulltext') }
end

def any_valid_wikidata_types?(types_to_check)
  valid_types = Set['newspaper', 'journal', 'magazine', 'periodical', 'serial']
  types_to_check.any? { |type| valid_types.include? type }
end

def select_periodicals_with_issns(periodicals)
  select_periodicals_only(periodicals)
    .map { |periodical| extract_issn(periodical) }
    .compact
end

def fix_trailing_article(title)
  title.gsub(/,\sThe/, '')
end
