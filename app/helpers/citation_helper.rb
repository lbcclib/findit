module CitationHelper
    include BlacklightHelper
    include ActionView::Helpers::TextHelper


    def create_bibtex(document)
    # A backup for creating a brief BibTeX string in case it wasn't added in the indexing step
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

    
    def generate_citations(document)
       if document.has? 'bibtex_t'
         begin
           if document['bibtex_t'].is_a?(Array)
             b = BibTeX.parse(document['bibtex_t'][0])
           elsif document['bibtex_t'].is_a?(String)
             b = BibTeX.parse(document['bibtex_t'])
           else
             b = BibTeX.parse(document['bibtex_t'].to_s)
	   end
	 rescue BibTeX::ParseError
	 #If parsing the text from index time absolutely doesn't work, create a new BibTeX string on the fly
           b = BibTeX.parse(create_bibtex(document))
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
             citations[shortname] = processor.render(:bibliography, id: 'resource').first.tr('{}', '')
          else
             #citations[shortname] = 'Citations not available at this time'
             citations[shortname] = document['bibtex_t']
          end
       end
       return citations
    end


end
