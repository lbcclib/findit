# frozen_string_literal: true

USER_AGENT = 'LBCC library (libref@linnbenton.edu) Ruby 2.6'

require 'csv'
require 'sparql/client'

namespace :findit do
  namespace :data do
    namespace :index do
      task sample_articles: :environment do
        index_holdings_from_kbart filename: Rails.root.join('spec/fixtures/files/kbart.txt')
      end
    end
  end
end

def index_holdings_from_kbart(filename:)
  CSV.read(filename, 'r', col_sep: "\t", headers: true, quote_char: "\x00",
                          encoding: 'utf-8').each_slice(10) do |periodicals|
    periodicals, wikidata_articles = get_periodical_metadata_and_articles_from_wikidata periodicals
    crossref_articles = get_articles_from_crossref periodicals
    articles = deduplicate_articles wikidata: wikidata_articles, crossref: crossref_articles
    write_to_solr periodicals
    write_to_solr articles
  end
end

def get_periodical_metadata_and_articles_from_wikidata(periodicals)
  # TODO: don't just do ISSN ones!
  issn_periodicals = select_periodicals_with_issns(periodicals)
  periodical_data = issn_periodicals.map { |issn| fetch_periodical_data_from_wikidata(issn) }
  [periodical_data, []]
end

def extract_issn(row)
  good_issn = StdNum::ISSN.normalize(row['print_identifier']) || StdNum::ISSN.normalize(row['online_identifier'])

  # STDNum library strips out the hyphens, but wikidata uses hyphens.  Add them back in if it is a valid ISSN
  good_issn ? good_issn.insert(4, '-') : nil
end

def fetch_periodical_data_from_wikidata(issn)
  client = SPARQL::Client.new(
    'https://query.wikidata.org/sparql',
    method: :get,
    headers: { 'User-Agent': USER_AGENT }
  )
  query = <<~ENDQUERY
        SELECT ?journal ?journalLabel ?languageLabel ?journalDescription ?placeOfPublicationLabel ?formatLabel ?issn WHERE {
        ?journal wdt:P236 "#{issn}" .
    #{'    '}
        OPTIONAL{?journal wdt:P31 ?format} .
        OPTIONAL{?journal wdt:P495 ?placeOfPublication}  .
        OPTIONAL{?journal wdt:P407 ?language}  .
        OPTIONAL{?journal wdt:P236 ?issn}  .
        SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
        }
  ENDQUERY
  periodical_rdf_to_solr client.query(query)
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

def periodical_rdf_to_solr(response)
  periodical = response.map(&:to_h)
  return nil unless periodical&.first

  {
    id: periodical.first[:journal].to_s.gsub('http://www.wikidata.org/entity/', ''),
    format: periodical.first[:formatLabel].to_s.capitalize || 'Periodical',
    place_of_publication_t: periodical.first[:placeOfPublicationLabel].to_s,
    abstract_t: periodical.first[:journalDescription].to_s,
    issn_t: periodical.first[:issn].to_s,
    title_t: periodical.first[:journalLabel].to_s.capitalize
  }
end

def select_periodicals_with_issns(periodicals)
  periodicals.select { |row| row && (row['coverage_depth'] == 'fulltext') }
             .map { |row| extract_issn(row) }
             .compact
end
