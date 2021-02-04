# frozen_string_literal: true

require_relative './helpers'

module Traject
  module Macros
    module LbccFormats
      # very opionated macro that just adds a grab bag of format/genre/types
      # from our own custom vocabulary, all into one field.
      # You may want to build your own from MarcFormatClassifier functions instead.
      #
      def lbcc_formats
        lambda do |record, accumulator|
          accumulator.concat Traject::Macros::LbccFormatClassifier.new(record).formats
        end
      end
    end

    # A tool for classifiying MARC records according to format/form/genre/type,
    # just using our own custom vocabulary for those things.
    #
    # used by the `lbcc_formats` macro, but you can also use it directly
    # for a bit more control.
    class LbccFormatClassifier
      include FindIt::Data
      attr_reader :record

      def initialize(marc_record)
        @record = marc_record
      end

      # A very opinionated method that just kind of jams together
      # all the possible format/genre/types into one array of 1 to N elements.
      #
      # If no other values are present, the default value "Other" will be used.
      #
      # See also individual methods which you can use you seperate into
      # different facets or do other custom things.
      def formats(options = {})
        options = { default: 'Unknown' }.merge(options)

        formats = []

        formats.concat online_resource?(record) ? online_format : physical_format

        field = record['008']&.value
        if field && (field[23] == 'o')
          if formats.include? 'Book'
            formats.delete('Book')
            formats << 'Ebook'
          elsif formats.include? 'Serial'
            formats.delete('Serial')
            formats << 'Electronic journal'
          elsif formats.include? 'Video'
            formats.delete('Video')
            formats << 'Streaming video'
          end
        end

        formats << options[:default] if formats.empty?

        Array(formats[0])
      end

      private

      def online_format
        map = Traject::TranslationMap.new('marc_online_genre_leader')
        results = marc_format_from_leader map
        [results].flatten
      end

      # Returns 1 or more values in an array
      # Uses leader byte 6, leader byte 7, and 007 byte 0.
      def physical_format
        leader_map = Traject::TranslationMap.new('marc_genre_leader_lbcc')
        physical_description_map = Traject::TranslationMap.new('marc_genre_007_lbcc')

        results = marc_format_from_leader(leader_map) ||
                  record.find_all { |f| f.tag == '007' }.collect { |f| physical_description_map[f.value.slice(0)] }

        [results].flatten
      end

      def marc_format_from_leader(map)
        map[@record.leader.slice(6, 2)] ||
          map[@record.leader.slice(6)]
      end
    end
  end
end
