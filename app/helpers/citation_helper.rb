# Functions related to citations, which might be a bit more sophisticated
# than simple view helpers and should therefore probably be eventually moved
# into model/controller
module CitationHelper
    include BlacklightHelper
    include ActionView::Helpers::TextHelper

    # Creates a one-item BibTeX bibliography in case the app can't find one
    # in the data from Solr.
    def create_bibtex(document)
       biblio = BibTeX::Bibliography.new
       biblio << BibTeX::Entry.new( extract_bibliographic_data_from (document))
       biblio[0].key = 'resource'
       return biblio
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
           b = create_bibtex document
	 end
       else
	 # Creates a minimal BibTeX string from solr data if
	 # there is no BibTeX in the solr document.
         b = create_bibtex document
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
       styles['CSE'] = CiteProc::Processor.new format: 'html', style: 'council-of-science-editors'
       
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

    private

    # Returns a hash with the most important information about
    # the given solr document
    def extract_bibliographic_data_from document
       bib_entry = {
           bibtex_type: bibtex_type(document['type']),
           title: document['title_display'],
       }
       if document.has? 'author_display'
           bib_entry[:author] = document['author_display']
       end
       if document.has? 'pub_date'
          bib_entry[:year] = document['pub_date'][0]
       end
       if document.has? 'publisher_display'
          if document['publisher_display'].is_a?(Array)
             bib_entry[:publisher] = document['publisher_display'][0]
          else
             bib_entry[:publisher] = document['publisher_display'].to_s
          end
       end
       return bib_entry
    end

    # Returns a symbol representing the BibTeX type that corresponds
    # to the string you pass to it
    def bibtex_type solr_type
        if ['Ebook', 'Book'].include? solr_type
            return :book
        elsif ['Article'].include? solr_type
            return :article
        else
            return :misc
        end
    end


end
