# frozen_string_literal: true

require_relative './helpers'

module FindIt
  module Macros
    # very opionated macro that just adds a grab bag of format/genre/types
    # from our own custom vocabulary, all into one field.
    module LBCCFormats
      def self.lbcc_formats
        lambda do |record, accumulator|
          accumulator.concat FindIt::Macros::LBCCFormatClassifier.new(record).formats
        end
      end
    end

    # A tool for classifiying MARC records according to format/form/genre/type,
    # just using our own custom vocabulary for those things.
    #
    # used by the `lbcc_formats` macro, but you can also use it directly
    # for a bit more control.
    class LBCCFormatClassifier
      include FindIt::Data
      attr_reader :record

      def initialize(marc_record)
        @record = marc_record
      end

      # A very opinionated method that just kind of jams together
      # all the possible format/genre/types into one array of 1 to N elements.
      def formats
        formats = online_resource?(record) ? online_format : physical_format
        any_found?(formats) ? Array(formats[0]) : nil
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

      def any_found?(formats)
        formats.any? && formats.first
      end
    end
  end
end
