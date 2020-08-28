# frozen_string_literal: true

module Traject
  module Macros
    # To use the lbcc_format macro, in your configuration file:
    #
    #     extend Traject::Macros::LbccFormats
    #
    #     to_field "format", lbcc_formats
    #
    # See also MarcClassifier which can be used directly for a bit more
    # control.
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

        formats.concat genre

        begin
          f8_23 = record['008'].value[23]
        rescue NoMethodError
          return []
        end
        if f8_23 == 'o'
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

      # Returns 1 or more values in an array from:
      # Book; Journal/Newspaper; Musical Score; Map/Globe; Non-musical Recording; Musical Recording
      # Image; Software/Data; Video/Film
      #
      # Uses leader byte 6, leader byte 7, and 007 byte 0.
      #
      # Gets actual labels from marc_genre_leader and marc_genre_007 translation maps,
      # so you can customize labels if you want.
      def genre
        marc_genre_leader = Traject::TranslationMap.new('marc_genre_leader_lbcc')
        marc_genre_007    = Traject::TranslationMap.new('marc_genre_007_lbcc')

        results = marc_genre_leader[record.leader.slice(6, 2)] ||
                  marc_genre_leader[record.leader.slice(6)] ||
                  record.find_all { |f| f.tag == '007' }.collect { |f| marc_genre_007[f.value.slice(0)] }

        [results].flatten
      end
    end
  end
end
