# frozen_string_literal: true

require 'active_support'
require 'active_support/cache/mem_cache_store'

AUTHORIZED_BIB_TAGS = %w[100 110 111 600 610 611 630 650 651 700 710].freeze
INTERESTING_AUTHORITY_TAGS = %w[400 410 411 430 447 448 450 451 455 500 510 511 530 550 551
                                555 681 682 700 710 711 730 747 748 750 751 755 780 781 782].freeze
USELESS_AUTHORITY_SUBFIELD_CODES = %w[0 4 d i w].freeze

module FindIt
  module Macros
    # Checks the Evergreen authority file for additional
    # keywords to index
    module EgAuthorityControl
      @@cache = ::ActiveSupport::Cache::MemCacheStore.new 'memcached:11211' # rubocop:disable Style/ClassVars

      @@logger = Yell.new($stderr, level: 'debug') # rubocop:disable Style/ClassVars

      def keywords_from_linked_authority_records
        proc do |record, accumulator|
          record.find_all { |f| AUTHORIZED_BIB_TAGS.include? f.tag }.each do |field|
            accumulator.concat(field.find_all { |subfield| subfield.code == '0' }
                 .map do |subfield|
                                 Thread.new do
                                   fetch_and_extract_authority_record subfield.value.delete('^0-9')
                                 end
                               end.map(&:value))
          end
        end
      end

      def fetch_and_extract_authority_record(authority_id)
        @@logger.info "Found cached authority record #{authority_id}" if @@cache.exist? cache_id(authority_id)
        @@cache.fetch(cache_id(authority_id)) do
          eg_authority_url = 'http://libcat.linnbenton.edu/opac/extras/supercat/'\
                             "retrieve/marcxml/authority/#{authority_id}"
          begin
            URI.parse(eg_authority_url).open do |file|
              record = MARC::XMLReader.new(file).first
              extract_keywords_from_authority_record record if record
            end
          rescue Errno::ECONNREFUSED, Errno::ECONNRESET, OpenSSL::SSL::SSLError, OpenURI::HTTPError, Net::OpenTimeout, SocketError
            []
          end
        end
      end

      def extract_keywords_from_authority_record(record)
        keywords = []
        record.find_all { |f| INTERESTING_AUTHORITY_TAGS.include? f.tag }.each do |afield|
          keywords.concat(
            afield.reject { |sf| USELESS_AUTHORITY_SUBFIELD_CODES.include? sf.code }
                  .map(&:value)
          )
        end
        @@logger.debug "Authority keywords found: #{keywords}" if keywords.any?
        keywords
      end

      def cache_id(authority_record_id)
        "authority_record_#{authority_record_id}"
      end
    end
  end
end
