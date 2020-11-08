# frozen_string_literal: true

require 'bibtex'
require 'traject/macros/marc21'
require 'traject/macros/marc21_semantics'
# include Traject::Macros::Marc21
# include Traject::Macros::Marc21

PUBLICATION_TAGS = %w[260 264].freeze

module FindIt
  module Macros
    #     extend Traject::Macros::BibTeX
    #     to_field "bibtex_t", generate_bibtex
    module Bibtex
      # macro that generates a basic bibtex entry for an item
      def generate_bibtex
        lambda do |record, accumulator|
          accumulator.concat FindIt::Macros::BibtexGenerator.new(record).bibtex_string
        end
      end
    end

    class BibtexGenerator
      attr_reader :record

      def initialize(marc_record)
        @record = marc_record
      end

      def bibtex_string(_options = {})
        Array(compile_string)
      end

      def compile_string
        m245 = record['245']
        title = ::Traject::Macros::Marc21.trim_punctuation(m245['a'].strip)

        author_fields = %w[100 700]
        authors = []
        auth_fields = record.find_all { |f| author_fields.include? f.tag }
        auth_fields.each do |field|
          auth_subfields = field.find_all { |sf| sf.code == 'a' }
          auth_subfields.each do |sf|
            authors << sf.value
          end
        end

        addresses = []
        publishers = []
        pub_fields = record.find_all { |f| PUBLICATION_TAGS.include? f.tag }
        pub_fields.each do |field|
          addresses << field['a']
          publishers << field['b']
        end

        url = nil

        begin
          f8_23 = record['008'].value[23]
          if f8_23 == 'o'
            bibtex_type = 'misc'
            urls = record.find_all { |f| f.tag == '856' }
            url = urls.first['u']
          else
            bibtex_type = 'book'
          end
        rescue NoMethodError
          bibtex_type = 'book'
        end

        bib_data = {
          bibtex_type: bibtex_type,
          title: title
        }
        bib_data['author'] = authors.join(' and ') unless authors.empty?
        bib_data['address'] = addresses[0] unless addresses.empty?
        bib_data['publisher'] = publishers[0] unless publishers.empty?
        bib_data['year'] = ::Traject::Macros::Marc21Semantics.publication_date(record, 15, 1000, Time.new.year + 6)
        bib_data['url'] = url unless url.nil?
        biblio = BibTeX::Bibliography.new
        biblio << BibTeX::Entry.new(bib_data)
        biblio[0].key = 'resource'
        biblio.to_s
      end
    end
  end
end
