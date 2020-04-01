require 'bibtex'
module Traject
  module Macros
    #     require 'traject/macros/generate_bibtex'
    #     extend Traject::Macros::BibTeX
    #     to_field "bibtex_t", generate_bibtex
    module BibtexForTraject
      # macro that generates a basic bibtex entry for an item
      def generate_bibtex
        lambda do |record, accumulator|
            accumulator.concat Traject::Macros::BibtexGenerator.new(record).bibtex_string
        end
      end
    end


    class BibtexGenerator
      attr_reader :record

      def initialize(marc_record)
        @record = marc_record
      end

      def bibtex_string(options = {})
        return Array(compile_string)
      end


      def compile_string
        m245 = record['245']
	title = Marc21.trim_punctuation(m245['a'].strip)

        author_fields = ['100', '700']
        authors = []
        auth_fields = record.find_all {|f| author_fields.include? f.tag}
        auth_fields.each do |field|
            auth_subfields = field.find_all {|sf| 'a' == sf.code}
	    auth_subfields.each do |sf|
	        authors << sf.value
            end
        end

        addresses = []
        publishers = []
        pub_fields = record.find_all {|f| ['260', '264'].include? f.tag}
        pub_fields.each do |field|
            addresses << field['a']
            publishers << field['b']
        end

	url = nil

        begin
            f8_23 = record['008'].value[23]
            if 'o' == f8_23
                bibtex_type = 'misc'
                urls = record.find_all {|f| f.tag == '856'}
                url = urls.first['u']
            else
                bibtex_type = 'book'
            end
        rescue NoMethodError
            bibtex_type = 'book'
        end

        bib_data = {
          bibtex_type: bibtex_type,
          title: title,
        }
        unless authors.empty?
          bib_data['author'] = authors.join(' and ')
        end
        unless addresses.empty?
          bib_data['address'] = addresses[0]
        end
        unless publishers.empty?
          bib_data['publisher'] = publishers[0]
        end
	bib_data['year'] = Marc21Semantics.publication_date(record, 15, 1000, Time.new.year + 6)
        unless url.nil?
          bib_data['url'] = url
        end
        biblio = BibTeX::Bibliography.new
        biblio << BibTeX::Entry.new(bib_data)
        biblio[0].key = 'resource'
        return biblio.to_s
      end

    end
  end
end

