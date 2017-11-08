# Journal and newspaper articles taken from an external API
class Article < SolrDocument
#    attr_reader :abstract, :authors, :db, :id, :journal, :title, :type, :url_fulltext_display, :year
    PROXY_PREFIX = 'http://ezproxy.libweb.linnbenton.edu:2048/login?url='

    # Fills an Article object up with data from an API
    def extract_data_from record
        if record.record['PLink'] and record.title
        #if record['PLink'] and record['RecordInfo']['BibRecord']['BibEntity']['Titles'].first['TitleFull']
            @_source[:title] = ActionView::Base.full_sanitizer.sanitize(Nokogiri::HTML.parse(record.title).text).html_safe
	    @_source[:url_fulltext_display] = [PROXY_PREFIX + record.record['PLink']]
	    @_source[:db] = record.database_id
            @_source[:id] = record.accession_number
            @_source[:pubtype] = record.publication_type
            @_source[:article_author_display] = record.authors
            @_source[:article_language_facet] = record.languages
	    @_source[:article_subject_facet] = record.subjects
            @_source[:database_display] = record.database_name
	    @_source[:pub_date] = record.publication_year

            @_source[:bibtex_t] = try_to_extract record, :retrieve_bibtex
	    @_source[:journal_display] = try_to_extract record, :source_title
	    @_source[:abstract_display] = try_to_extract record, :abstract
	    @_source[:doi_display] = try_to_extract record, :doi
	    @_source[:page_count_display] = try_to_extract record, :page_count
	    @_source[:page_number_display] = try_to_extract record, :page_start
	    @_source[:publisher_info_display] = try_to_extract record, :publication_info
	    @_source[:thumbnail_url_display] = try_to_extract record, :cover_thumb_url
	    @_source[:volume_display] = try_to_extract record, :volume
	    @_source[:issue_display] = try_to_extract record, :issue
	    @_source[:notes_display] = try_to_extract record, :notes
        end
    end

    private
    def try_to_extract record, field
      return record.send field
    rescue NoMethodError
      return false
    end

end
