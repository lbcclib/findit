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
  # TODO: don't just do ISSN ones! Insted, this should be like:
  # periodicals.map do |periodical| fetch_by_issn || fetch_by_title || fetch_by_something_else, each returning nil if it can't find anything
  periodical_data = select_periodicals_only(periodicals).map { |periodical| fetch_periodical_data_from_wikidata_by_issn(periodical) }
  [periodical_data, []]
end

def extract_issn(row)
  good_issn = StdNum::ISSN.normalize(row['print_identifier']) || StdNum::ISSN.normalize(row['online_identifier'])

  # STDNum library strips out the hyphens, but wikidata uses hyphens.  Add them back in if it is a valid ISSN
  good_issn ? good_issn.insert(4, '-') : nil
end

def fetch_periodical_data_from_wikidata_by_issn(periodical)
  issn = extract_issn(periodical)
  return nil unless issn

  client = WikidataConnection.new
  query = <<~ENDQUERY
        SELECT ?journal ?journalLabel ?languageLabel ?journalDescription ?placeOfPublicationLabel ?formatLabel ?issn WHERE {
        ?journal wdt:P236 "#{issn}" .
        OPTIONAL{?journal wdt:P31 ?format} .
        OPTIONAL{?journal wdt:P495 ?placeOfPublication}  .
        OPTIONAL{?journal wdt:P407 ?language}  .
        OPTIONAL{?journal wdt:P236 ?issn}  .
        SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
        }
  ENDQUERY
  periodical_rdf_to_solr(client.query(query), periodical['title_url'])
end

def get_articles_from_crossref(periodicals)
  # TODO: user agent
  # TODO: cache
  # TODO: follow all of the "NICE" rules for crossref api
  # TODO: if no link available, construct one using the link resolver
  # TODO: Index volume and issue

  documents = []
  select_periodicals_with_issns(periodicals).each do |issn|
    json = URI.parse("https://api.crossref.org/works?filter=issn:#{issn}&rows=1000").read
    result = JSON(json)
    result['message']['items'].each do |article|
      next unless article['title'] && article['link']

      document = {
        id: article['DOI'],
        format: article['type'],
        abstract_display: ActionController::Base.helpers.strip_tags(article['abstract']),
        is_electronic_facet: 'Online',
        publisher_display: article['publisher'],
        publisher_t: article['publisher'],
        pub_date: article['created']['date-parts'].first[0],
        record_provider_facet: 'Open access',
        record_source_facet: 'Open access',
        title_display: article['title'].first,
        title_t: article['title'].first,
        url_fulltext_display: article['link'].first['URL']
      }
      documents.push document
    end
  end
  documents
end

def deduplicate_articles(wikidata:, crossref:)
  crossref
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

def select_periodicals_with_issns(periodicals)
  select_periodicals_only(periodicals)
  .map {|periodical| extract_issn(periodical)}
  .compact
end
