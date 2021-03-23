# frozen_string_literal: true

require_relative 'lbcc_format.macro'

EBOOK_PROVIDERS = [
  'Wright American Fiction',
  'Brandeis University Press Open Access Ebooks',
  'All EBSCO eBooks',
  'Directory of Open Access Books',
  'Credo Academic Core',
  'NCBI Bookshelf'
].freeze

STREAMING_VIDEO_PROVIDERS = [
  'Academic Video Online: Premium United States',
  'American History in Video United States',
  'Films on Demand',
  'Films on Demand: Archival Films & Newsreels Collection - Academic',
  'Films on Demand: Master Career and Technical Education Collection - Academic'
].freeze

STREAMING_MUSIC_PROVIDERS = [
  'Music Online: Classical Music Library - United States',
  'Music Online: Smithsonian Global Sound for Libraries'
].freeze

module FindIt
  module Macros
    #     to_field "format", OCLCFormat.assign_format
    module OCLCFormat
      def self.assign_format
        proc do |record, accumulator|
          proposed_format = try_to_find_format record
          # Make sure that nothing is marked as a book due to bad OCLC data
          accumulator.push(proposed_format).compact! unless proposed_format == 'Book'
        end
      end

      def self.try_to_find_format(record)
        db = record['950']['a'].to_s
        return 'Ebook' if EBOOK_PROVIDERS.include? db
        return 'Streaming video' if STREAMING_VIDEO_PROVIDERS.include? db
        return 'Streaming music' if STREAMING_MUSIC_PROVIDERS.include? db

        FindIt::Macros::LBCCFormatClassifier.new(record).formats&.first
      end
    end
  end
end
