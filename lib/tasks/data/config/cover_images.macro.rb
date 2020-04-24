require 'net/http'
module FindIt
  module Macros
    module CoverImages

      def logger
        @logger ||= Yell.new(STDERR, :level => "debug")
      end

      def cover_image
        return proc do |record, accumulator|
          isbns = extract_identifiers '020', record
          isbns.each do |isbn|
            if image_exists 'isbn', isbn
              accumulator << ol_url('isbn', isbn, 'M')
              self.logger.info("Found image for record #{record['001']} using isbn #{isbn}")
              break
            end
          end

          lccns = extract_identifiers '020', record
          lccns.each do |lccn|
            if image_exists 'lccn', lccn
              accumulator << ol_url('lccn', lccn, 'M')
              self.logger.info("Found image for record #{record['001']} using lccn #{lccn}")
              break
            end
          end

          oclcs = extract_identifiers '035', record
          oclcs.each do |oclc|
            if image_exists 'oclc', oclc
              accumulator << ol_url('oclc', oclc, 'M')
              self.logger.info("Found image for record #{record['001']} using oclc num #{oclc}")
              break
            end
          end
        end
      end

      def extract_identifiers tag, record
        identifiers = []
        record.each_by_tag(tag) do |field|
          subfields = field.find_all do |sf|
            if (['a', 'z'].include? sf.code)
              identifiers << sf.value.delete('^0-9')
            end
          end
        end
        identifiers
      end


      def ol_url type, identifier, size
        "https://covers.openlibrary.org/b/#{type}/#{identifier}-#{size}.jpg?default=false"
      end

      def image_exists type, identifier
        begin
            # Try fetching a small version of the image to reduce network load
            response = Net::HTTP.get_response(URI.parse(ol_url type, identifier, 'S'))
        rescue
            return false
        end
        if response.body.include? 'not found'
            return false
        elsif ['200', '301', '302'].include? response.code
            return true
        end
        false
      end

    end
  end
end
