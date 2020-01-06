# Journal and newspaper articles taken from an external API
class Article < SolrDocument
    PROXY_PREFIX = 'https://ezproxy.libweb.linnbenton.edu/login?url='

    # Fills an Article object up with data from an API
    def initialize record
        @_source = HashWithIndifferentAccess.new
        if record.title
            @_source[:title] = record.title

            #Use the fulltext link if available, otherwise the plink
            record.eds_fulltext_links.each do |link|
              if ('detail' != link[:url])
                @_source[:url_fulltext_display] = PROXY_PREFIX + link[:url]
                break
              end
            end
            unless @_source.key? :url_fulltext_display
              @_source[:url_fulltext_display] = PROXY_PREFIX + record.eds_plink
            end

	    @_source[:db] = record.eds_database_id
            @_source[:id] = record.eds_accession_number
            @_source[:pubtype] = record.eds_publication_type
            @_source[:article_author_display] = record.eds_authors
            @_source[:article_language_facet] = record.eds_languages
	    @_source[:article_subject_facet] = record.eds_subjects
            @_source[:database_display] = record.eds_database_name
	    @_source[:pub_date] = record.eds_publication_year

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
        end
    end

    private
    def try_to_extract record, field
      return record.send field
    rescue NoMethodError
      return false
    end

end

