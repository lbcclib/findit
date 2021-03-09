# frozen_string_literal: true

require 'bibtex'
require 'traject/macros/marc21'
require 'traject/macros/marc21_semantics'
require 'active_support/core_ext/module' # Allows us to delegate to Bibtex
require_relative './helpers'

AUTHOR_TAGS = %w[100 700].freeze
PUBLICATION_TAGS = %w[260 264].freeze

module FindIt
  module Macros
    #     extend Traject::Macros::BibTeX
    #     to_field "bibtex_t", generate_bibtex
    module Bibtex
      # macro that generates a basic bibtex entry for an item
      def generate_bibtex
        proc do |record, accumulator|
          accumulator << FindIt::Macros::BibtexGenerator.new(record).to_s
        end
      end
    end

    # Create a Bibtex bibliography entry for a given MARC record
    class BibtexGenerator
      include FindIt::Data
      delegate :to_s, to: :@entry

      def initialize(marc_record)
        @entry = BibTeX::Entry.new
        @record = marc_record
        add_metadata
      end

      private

      def add_metadata
        add_authors
        add_publication_info
        add_title
        add_type
        add_url
      end

      def add_authors
        authors = @record.find_all { |f| AUTHOR_TAGS.include? f.tag }
                         .map { |f| f.find { |sf| sf.code == 'a' }&.value }
        @entry.author = authors.join(' and ') if authors
      end

      def add_publication_info
        pub_field = @record.find { |f| PUBLICATION_TAGS.include? f.tag }
        @entry.address = pub_field['a'] if pub_field && pub_field['a']
        @entry.publisher = pub_field['b'] if pub_field && pub_field['b']
      end

      def add_type
        @entry.type = online_resource?(@record) ? :misc : :book
      end

      def add_title
        @entry.title = ::Traject::Macros::Marc21.trim_punctuation @record['245']['a']
      end

      def add_url
        url = @record.find { |f| f.tag == '856' }
        @entry.url = url['u'] if url
      end

      def add_year
        @entry.year = ::Traject::Macros::Marc21Semantics.publication_date(@record)
      end
    end
  end
end
