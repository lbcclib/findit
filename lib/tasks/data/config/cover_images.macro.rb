# frozen_string_literal: true

require 'openlibrary/covers'

IDENTIFIER_TYPES_FOR_COVER_IMAGES = {
  'isbn' => '020',
  'lccn' => '010',
  'oclc' => '035'
}.freeze

IDENTIFIER_SUBFIELDS = %w[a z].freeze

module FindIt
  module Macros
    # Checks OpenLibrary to see if a cover image exists
    # for a given record, using a variety of identifiers
    module CoverImages
      def logger
        @logger ||= Yell.new($stderr, level: 'warn')
      end

      def cover_image
        proc do |record, accumulator|
          IDENTIFIER_TYPES_FOR_COVER_IMAGES.each do |id_type, tag|
            image = image_for id_type, tag, record
            if image.found?
              accumulator << image.url
              break
            end
          end
        end
      end

      def image_for(id_type, tag, record)
        identifiers = extract_identifiers tag, record
        image = Openlibrary::Covers::Image.new identifiers, id_type
        logger.info("Found image for record #{record['001']}: #{image.url}") if image.found?
        image
      end

      def extract_identifiers(tag, record)
        identifiers = []
        record.each_by_tag(tag) do |field|
          identifiers.concat(
            field.select { |sf| IDENTIFIER_SUBFIELDS.include? sf.code }
                 .map { |sf| sf.value.delete('^0-9') }
          )
        end
        identifiers
      end
    end
  end
end
