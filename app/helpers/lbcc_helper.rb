module LbccHelper
    include BlacklightHelper
    include ActionView::Helpers::TextHelper
    require 'nokogiri'
    require 'open-uri'
    require 'uri'

    def articles_desired()
        return request.parameters[:show_articles] == 'true' ? true : false
    end


    def create_bibtex(document)
       bibtex = '@book{resource, '
       if document.has? 'author_display'
          bibtex.concat('author = {' + document['author_display'].gsub(/[0-9\-]/, '') + '},')
       end
       bibtex.concat('title = {' + document['title_display'] + '}')
       if document.has? 'pub_date'
          bibtex.concat(', year = ' + document['pub_date'][0])
       end
       if document.has? 'publisher_display'
          if document['publisher_display'].is_a?(Array)
             bibtex.concat(', publisher = {' + document['publisher_display'][0] + '}')
          else
             bibtex.concat(', publisher = ' + document['publisher_display'].to_s + '}')
          end
       end
       bibtex.concat('}')
       return bibtex
    end

    
    def display_access_options(document, context)
    # Context options: show (individual record), index (search results)
        style = ('index' == context) ? 'simple' : 'fancy'
        if document.has? 'eg_tcn_t'
            tcn_value = render_index_field_value(:document => document, :field => 'eg_tcn_t')
            display_library_holdings(tcn_value, style)
        elsif document.has? 'url_fulltext_display'
            url_value = render_index_field_value(:document => document, :field => 'url_fulltext_display')
            display_fulltext_access_link(url_value, style)
        end
    end

    def generate_citations(document)
       if document.has? 'bibtex_t'
          if document['bibtex_t'].is_a?(Array)
             b = BibTeX.parse(document['bibtex_t'][0])
          elif document['bibtex_t'].is_a?(String)
             b = BibTeX.parse(document['bibtex_t'])
          else
             # this is weird, because is_a?(String) or respond_to?(to_str) aren't working
             b = BibTeX.parse(document['bibtex_t'].to_s)
          end
       else
          b = BibTeX.parse(create_bibtex(document))
       end
       styles = Hash.new
       citations = Hash.new
       styles['APA'] = CiteProc::Processor.new format: 'html', style: 'apa'
       styles['MLA'] = CiteProc::Processor.new format: 'html', style: 'modern-language-association'
       styles['Chicago'] = CiteProc::Processor.new format: 'html', style: 'chicago-fullnote-bibliography'
       styles['IEEE'] = CiteProc::Processor.new format: 'html', style: 'ieee'
       styles['CBE'] = CiteProc::Processor.new format: 'html', style: 'council-of-science-editors'
       styles.each do |shortname, processor|
          processor.import b.to_citeproc
          unless processor.empty?
             citations[shortname] = processor.render(:bibliography, id: 'resource').first
          else
             #citations[shortname] = 'Citations not available at this time'
             citations[shortname] = document['bibtex_t']
          end
       end
       return citations
    end


    def display_fulltext_access_link(url_value, style)
        access_link = <<-EOS
          <a href=#{url_value} class="btn btn-success" role="button" target="_blank">Access this resource</a>
        EOS
        return access_link.html_safe
    end

    def snippet options={}
        value = options[:value].join(' ')
        truncate(strip(value), length: 200, separator: ' ')
    end

    def strip(string)
        # Also strip preceeding [ or whitespace
        string.gsub!(/^[\*\s]*/, '')
        string.gsub!(/[,\-:;\s]*$/, '')
        return string
    end


end
