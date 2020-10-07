# frozen_string_literal: true

# Journal and newspaper articles taken from an external API
class Article < SolrDocument
  PROXY_PREFIX = 'https://ezproxy.libweb.linnbenton.edu/login?url='
  DOMAINS_THAT_DONT_NEED_PROXY = [
    'doaj.org/article',
    'arxiv.org/'
  ].freeze

  # Fills an Article object up with data from an API
  def initialize(record)
    @_source = HashWithIndifferentAccess.new
    if record.title
      @_source[:title] = record.title

      # The best full text links that EDS has to offer
      best_url = record.eds_fulltext_links.find do |link|
        ((link[:url] != 'detail') && (link[:type] != 'cataloglink') && (link[:label] != 'Full Text Finder'))
      end

      # The second tier of EDS links
      if best_url.nil?
        best_url = record.eds_fulltext_links.find do |link|
          ((link[:url] != 'detail') && (link[:type] != 'cataloglink'))
        end
      end

      # If we haven't found any good links yet, use the Plink
      best_url = best_url ? best_url[:url] : record.eds_plink

      @_source[:url_fulltext_display] = if DOMAINS_THAT_DONT_NEED_PROXY.any? { |domain| best_url.include? domain }
                                          best_url
                                        else
                                          PROXY_PREFIX + best_url
                                        end

      @_source[:db] = record.eds_database_id
      @_source[:id] = record.eds_accession_number
      @_source[:format] = record.eds_publication_type
      @_source[:article_author_display] = record.eds_authors
      @_source[:article_language_facet] = record.eds_languages
      @_source[:article_subject_facet] = record.eds_subjects
      @_source[:database_display] = record.eds_database_name
      @_source[:pub_date] = record.eds_publication_year
      @_source[:record_source_facet] = record.eds_database_name

      @_source[:journal_display] = try_to_extract record, :eds_source_title
      @_source[:abstract_display] = try_to_extract record, :eds_abstract
      @_source[:doi_display] = try_to_extract record, :eds_doi
      @_source[:page_count_display] = try_to_extract record, :eds_page_count
      @_source[:page_number_display] = try_to_extract record, :eds_page_start
      @_source[:publisher_info_display] = try_to_extract record, :eds_publication_info
      @_source[:thumbnail_url_display] = try_to_extract record, :eds_cover_thumb_url
      @_source[:volume_display] = try_to_extract record, :eds_volume
      @_source[:issue_display] = try_to_extract record, :eds_issue
      @_source[:notes_display] = try_to_extract record, :eds_notes
      @_source[:result_number] = try_to_extract record, :eds_result_id
    end
  end

  private

  def try_to_extract(record, field)
    record.send field
  rescue NoMethodError
    false
  end
end
