module CitationHelper
    include BlacklightHelper
    include ActionView::Helpers::TextHelper

    # Creates a minimal BibTeX string in case the app can't find one
    # in the data from Solr.
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

    # Generates a hash containing properly formatted HTML citations
    # using CiteProc based on BibTeX data found in a solr index.
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
	 # Creates a minimal BibTeX string from solr data if
	 # the official BibTeX string can't be parsed.
	 rescue BibTeX::ParseError
           b = BibTeX.parse(create_bibtex(document))
	 end
       else
	 # Creates a minimal BibTeX string from solr data if
	 # there is no BibTeX in the solr document.
         b = BibTeX.parse(create_bibtex(document))
       end
       
       styles = Hash.new
       citations = Hash.new
       
       # To add a new citation style:
       # * the hash key will display in Find It as the label
       #   for your citation style
       # * the style value is the name of the citation style
       #   as listed at https://github.com/citation-style-language/styles
       styles['APA'] = CiteProc::Processor.new format: 'html', style: 'apa'
       styles['MLA'] = CiteProc::Processor.new format: 'html', style: 'modern-language-association'
       styles['Chicago'] = CiteProc::Processor.new format: 'html', style: 'chicago-fullnote-bibliography'
       styles['IEEE'] = CiteProc::Processor.new format: 'html', style: 'ieee'
       styles['CBE'] = CiteProc::Processor.new format: 'html', style: 'council-of-science-editors'
       
       # Generates the actual HTML citation using data from the
       # variable 'b' (our BibTeX string) and using the styles
       # established in the hash 'styles.'
       styles.each do |shortname, processor|
          processor.import b.to_citeproc
          unless processor.empty?
             citations[shortname] = processor.render(:bibliography, id: 'resource').first.tr('{}', '')
          else
             # If CSL mysteriously can't parse the citation,
             # just return the metadata from the variable 'b'
             # (our BibTeX string.)
             citations[shortname] = b
          end
       end
       return citations
    end


end
