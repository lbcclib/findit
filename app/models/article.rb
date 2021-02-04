# frozen_string_literal: true

require 'cgi'

# Journal and newspaper articles taken from an external API
class Article < SolrDocument
  PROXY_PREFIX = 'https://ezproxy.libweb.linnbenton.edu/login?url='
  DOMAINS_THAT_DONT_NEED_PROXY = [
    'doaj.org/article',
    'arxiv.org/'
  ].freeze
  CORE_METADATA_MAPPING = {
    db: :eds_database_id,
    id: :eds_accession_number,
    format: :eds_publication_type,
    article_author_display: :eds_authors,
    article_language_facet: :eds_languages,
    article_subject_facet: :eds_subjects,
    database_display: :eds_database_name,
    pub_date: :eds_publication_year,
    record_source_facet: :eds_database_name
  }.freeze

  ADDITIONAL_METADATA_MAPPING = {
    journal_display: :eds_source_title,
    doi_display: :eds_doi,
    page_count_display: :eds_page_count,
    page_number_display: :eds_page_start,
    publisher_info_display: :eds_publication_info,
    thumbnail_url_display: :eds_cover_thumb_url,
    volume_display: :eds_volume,
    issue_display: :eds_issue,
    notes_display: :eds_notes,
    result_number: :eds_result_id
  }.freeze

  # Fills an Article object up with data from an API
  # rubocop:disable Lint/MissingSuper
  def initialize(record)
    return unless record.title

    extract_metadata record
  end
  # rubocop:enable Lint/MissingSuper

  private

  def extract_metadata(record)
    @_source = HashWithIndifferentAccess.new
    @_source[:title] = record.title
    @_source[:url_fulltext_display] = best_url_in record

    CORE_METADATA_MAPPING.each { |ours, theirs| @_source[ours] = record.send theirs }

    ADDITIONAL_METADATA_MAPPING.each do |ours, theirs|
      @_source[ours] = try_to_extract record, theirs
    end

    add_abstract record
  end

  # Abstract requires special handling, since it may contain HTML tags
  def add_abstract(record)
    abstract = try_to_extract(record, :eds_abstract)
    @_source[:abstract_display] = CGI.unescapeHTML(abstract) if abstract
  end

  def try_to_extract(record, field)
    record.respond_to?(field) ? record.send(field) : false
  end

  def best_url_in(record)
    # The best full text links that EDS has to offer
    best_url = record.eds_fulltext_links.find { |link| non_ftf_catalog_link? link } ||
               record.eds_fulltext_links.find { |link| catalog_link? link }

    apply_proxy_if_appropriate best_url ? best_url[:url] : record.eds_plink
  end

  def apply_proxy_if_appropriate(url)
    if DOMAINS_THAT_DONT_NEED_PROXY.any? { |domain| url.include? domain }
      url
    else
      PROXY_PREFIX + url
    end
  end

  def catalog_link?(link)
    (link[:url] != 'detail') && (link[:type] != 'cataloglink')
  end

  def non_ftf_catalog_link?(link)
    catalog_link?(link) && (link[:label] != 'Full Text Finder')
  end
end
