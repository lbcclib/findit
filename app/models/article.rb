# Journal and newspaper articles taken from an external API
class Article < SolrDocument
#    attr_reader :abstract, :authors, :db, :id, :journal, :title, :type, :url_fulltext_display, :year
    PROXY_PREFIX = 'http://ezproxy.libweb.linnbenton.edu:2048/login?url='

    def extract_data_from record
        if record.record['PLink'] and record.title
        #if record['PLink'] and record['RecordInfo']['BibRecord']['BibEntity']['Titles'].first['TitleFull']
            @_source[:title] = Nokogiri::HTML.parse(record.title).text
	    @_source[:url_fulltext_display] = [PROXY_PREFIX + record.record['PLink']]
            @_source[:db] = record.dbid
            @_source[:id] = record.an
            if record.pubtype
                @_source[:pubtype] = record.pubtype
            end
            @_source[:article_author_display] = record.authors_raw
            @_source[:pub_date] = record.pubyear
            extract_journal_name_from_api_response record
            record.record['Items'].each do |item|
                if 'Abstract' == item['Name']
                    @_source[:abstract_display] = Nokogiri::HTML.parse(item['Data']).text
                end
            end
        end
    end

    private
    def extract_journal_name_from_api_response record
        begin
            @_source[:journal_display] = record.record['RecordInfo']['BibRecord']['BibRelationships']['IsPartOfRelationships'].first['BibEntity']['Titles'].first['TitleFull']
        rescue NoMethodError
            @_source[:journal_display] = "Unknown journal"	
        end
    end


end
