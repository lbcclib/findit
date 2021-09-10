# frozen_string_literal: true

class Periodical
  include ActiveModel::Validations
  attr_reader :issn, :qid, :title

  validates :qid, presence: true
  validates :title, presence: true

  # TODO: Add a way to check if two periodicals are the same
  # TODO: Add a way to merge two periodicals (e.g. if we have the same periodical listed twice in the KBART file, but with different full-text coverage)
  # TODO: Record the full-text coverage from KBART and apply it to the crossref and wikidata queries
  def initialize(kbart_row)
    @qid = nil

    is_periodical(kbart_row) ? get_metadata_from_kbart(kbart_row) : handle_non_periodical
    return unless @issn || @title # no need to process anymore

    fetch_periodical_data_from_wikidata_by_issn || fetch_periodical_data_from_wikidata_by_title
  end

  def to_solr
    {
      id: @qid,
      format: @format,
      place_of_publication_t: @place_of_publication,
      abstract_t: @abstract,
      issn_t: @issn,
      record_source_facet: @database,
      title_t: @title,
      title_display: @title,
      language_facet: @language,
      is_electronic_facet: 'Online',
      url_fulltext_display: @url
    }
  end

  def articles
    crossref = articles_from_crossref
    wikidata = articles_from_wikidata
    deduplicate_articles crossref, wikidata
  end

  private

  def is_periodical(kbart_row)
    kbart_row && (kbart_row['coverage_depth'] == 'fulltext')
  end

  def get_metadata_from_kbart(kbart_row)
    @issn = extract_issn(kbart_row)
    @title = fix_trailing_article kbart_row['publication_title']
    @url = ResourceLink.new(kbart_row['title_url']).to_s
    @database = kbart_row['oclc_collection_name']
  end

  def handle_non_periodical
    @issn = nil
    @title = nil
  end

  # TODO: handle duplicates we recieve from a single source (e.g. if wikidata has two items for the same article)
  def deduplicate_articles(wikidata, crossref)
    puts "DEDUPING #{@title}"
    crossref.concat(wikidata.reject { |article| crossref.include? article })
  end

  def fetch_periodical_data_from_wikidata_by_issn
    return nil unless @issn

    journal_metadata_query("?journal wdt:P236 \"#{@issn}\" .")
  end

  def fetch_periodical_data_from_wikidata_by_title
    return nil unless @title

    uri = URI.parse "https://wikidata.reconci.link/en/api?queries=#{{ 'q1' => { 'query' => @title,
                                                                                'limit' => 1 } }.to_json}"
    response = JSON.parse(Net::HTTP.get(uri))
    return nil unless response

    results = response['q1']['result']
    return nil unless results.any?

    qid = results&.first['id']
    types = results&.first['type'].map { |type| type['name'] }
    return nil unless qid && any_valid_wikidata_types?(types)

    journal_metadata_query(
      "VALUES ?journal {wd:#{qid}}"
    )
  end

  def fix_trailing_article(title)
    title.gsub(/,\sThe/, '')
  end

  def journal_metadata_query(where_clause)
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
    parse_rdf(client.query(query))
  end

  def parse_rdf(results)
    return nil unless results&.first

    @qid = results.first[:journal].to_s.gsub('http://www.wikidata.org/entity/', '')
    return nil unless @qid

    @format = results.first[:formatLabel].to_s.capitalize || 'Periodical'
    @place_of_publication = results.first[:placeOfPublicationLabel].to_s
    @abstract = results.first[:journalDescription].to_s
    @issn = results.first[:issn].to_s
    @title = results.first[:journalLabel].to_s
    @title_display = results.first[:journalLabel].to_s
    @language = results.first[:languageLabel].to_s.capitalize
  end

  def extract_issn(kbart_row)
    good_issn = StdNum::ISSN.normalize(kbart_row['print_identifier']) ||
                StdNum::ISSN.normalize(kbart_row['online_identifier'])

    # STDNum library strips out the hyphens, but wikidata uses hyphens.  Add them back in if it is a valid ISSN
    good_issn ? good_issn.insert(4, '-') : nil
  end

  def articles_from_crossref
    # TODO: user agent
    # TODO: cache
    # TODO: follow all of the "NICE" rules for crossref api
    # TODO: if no link available, construct one using the link resolver

    articles = []
    return articles if @issn.blank?

    Rails.logger.debug do
      "Getting Crossref articles from URL https://api.crossref.org/works?filter=issn:#{@issn}&rows=1000"
    end
    json = URI.parse("https://api.crossref.org/works?filter=issn:#{@issn}&rows=1000").read
    result = JSON(json)
    result['message']['items'].each do |article|
      next unless article['title'] && article['link']

      article = Article.new crossref: article
      articles.push article
    end
    articles
  end

  def articles_from_wikidata
    client = WikidataConnection.new
    query = <<~ENDQUERY
      CONSTRUCT {
        ?article wdt:P2093 ?authorStrings ;
          wdt:P2093 ?authorLabel ;
          wdt:P356 ?doi  ;
          wdt:P433 ?issue ;
          wdt:P1433 ?journalLabel ;
          wdt:P407 ?languageLabel ;
          wdt:P304 ?pages ;
          wdt:P304 ?pubDate ;
          wdt:P921 ?subjectLabel ;
          wdt:P1476 ?title ;
          wdt:P1476 ?articleLabel ;
          wdt:P31 ?typeLabel ;
          wdt:P478 ?volume .
      }
      WHERE {
        VALUES ?journal {wd:#{@qid}}
        ?article wdt:P1433 ?journal ;
          wdt:P31 ?type.
        OPTIONAL {?article wdt:P2093 ?authorStrings }
        OPTIONAL {?article wdt:1476 ?title }
        OPTIONAL {?article wdt:P356 ?doi }
        OPTIONAL {?article wdt:P433 ?issue }
        OPTIONAL {?article wdt:P304 ?pages }
        OPTIONAL {?article wdt:P304 ?pubDate }
        OPTIONAL {?article wdt:P478 ?volume }
        OPTIONAL {?article wdt:P50 ?author }
        OPTIONAL {?article wdt:P1433 ?journal }
        OPTIONAL {?article wdt:P407 ?language }
        OPTIONAL {?article wdt:P921 ?subject }
        SERVICE wikibase:label { bd:serviceParam wikibase:language "en,es". }
      }
    ENDQUERY
    Rails.logger.info query
    results = client.query query
    return [] unless results

    article_uris = results.pluck(:subject).uniq

    article_uris.map do |uri|
      matching_triples = results.select { |triple| triple[:subject] == uri }
      Article.new(wikidata: matching_triples)
    end
  end

  def any_valid_wikidata_types?(types_to_check)
    valid_types = Set['newspaper', 'journal', 'magazine', 'periodical', 'serial']
    types_to_check.any? { |type| valid_types.include? type }
  end
end
