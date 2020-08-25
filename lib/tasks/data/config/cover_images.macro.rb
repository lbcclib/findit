# frozen_string_literal: true

require 'net/http'

IDENTIFIER_TYPES_FOR_COVER_IMAGES = {
  'isbn' => '020',
  'lccn' => '010',
  'oclc' => '035'
}.freeze

module FindIt
  module Macros
    # Checks OpenLibrary to see if a cover image exists
    # for a given record, using a variety of identifiers
    module CoverImages
      def logger
        @logger ||= Yell.new(STDERR, level: 'debug')
      end

      def cover_image
        proc do |record, accumulator|
          IDENTIFIER_TYPES_FOR_COVER_IMAGES.each do |id_type, tag|
            image_url = fetch_valid_image_url id_type, tag, record
            if image_url
              accumulator << image_url
              break
            end
          end
        end
      end

      def fetch_valid_image_url(id_type, tag, record)
        identifiers = extract_identifiers tag, record
        identifiers.each do |identifier|
          next unless image_exists id_type, identifier

          logger.info("Found image for record #{record['001']} using #{id_type} #{identifier}")
          return ol_url(id_type, identifier, 'M')
        end
        false
      end

      def extract_identifiers(tag, record)
        identifiers = []
        record.each_by_tag(tag) do |field|
          field.find_all do |sf|
            identifiers << sf.value.delete('^0-9') if %w[a z].include? sf.code
          end
        end
        identifiers
      end

      def ol_url(type, identifier, size)
        "https://covers.openlibrary.org/b/#{type}/#{identifier}-#{size}.jpg?default=false"
      end

      def image_exists(type, identifier)
        begin
          # Try fetching a small version of the image to reduce network load
          response = Net::HTTP.get_response(URI.parse(ol_url(type, identifier, 'S')))
        rescue StandardError
          return false
        end
        return false if response.body.include? 'not found'
        return true if %w[200 301 302].include? response.code

        false
      end
    end
  end
end
