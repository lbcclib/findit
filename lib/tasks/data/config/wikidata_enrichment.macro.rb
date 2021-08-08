# frozen_string_literal: true

AUTHORIZED_BIB_TAGS = %w[100 110 111 600 610 611 630 650 651 700 710].freeze

require_relative '../../../../app/models/wikidata_connection'

module FindIt
  module Macros
    # Checks Wikidata for additional keywords to index
    module WikidataEnrichment
      def keywords_from_wikidata
        proc do |record, accumulator|
          uris_from_bib_record = []
          record.find_all { |f| AUTHORIZED_BIB_TAGS.include? f.tag }.each do |field|
            uris_from_bib_record.concat(field.find_all { |subfield| subfield.code == '9' }.map(&:to_s))
          end
          accumulator.concat(keywords_for_uris(uris_from_bib_record))
        end
      end

      def keywords_for_uris(uris)
        identifier_string = stringify_identifiers(uris_to_identifiers(uris))
        wikidata_results identifier_string
      end

      def wikidata_results(identifier_string)
        client = WikidataConnection.new
        query = compile_query identifier_string
        results = client.query(query)
        results.map { |keyword| keyword[:keywordLabel].to_s }
      end

      def compile_query(identifier_string)
        <<~ENDQUERY
          SELECT DISTINCT ?keywordLabel
          WHERE
          {
            VALUES ?authorities { #{identifier_string} }
            ?nameProperties wdt:P1647* wd:P2561.
            ?nameProperties wikibase:directClaim ?nameClaim .
            ?item wdt:P244 ?authorities.
            {?item
                  (wdt:P17|wdt:P101|wdt:P112|wdt:P135|wdt:P136|wdt:P279|wdt:P361|wdt:P460|wdt:P793|wdt:P800|wdt:P1269|wdt:P1344|wdt:P1830|p:P2572/ps:P2572|wdt:P3342|wdt:P3602|wdt:P5004) ?keyword.}
            UNION
            {?item ?nameClaim ?keyword}

            SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en,es". }
          }
        ENDQUERY
      end

      def stringify_identifiers(identifiers)
        identifiers.map { |identifier| "\"#{identifier}\"" }
                   .join(' ')
      end

      def uris_to_identifiers(uris)
        uris.map { |uri| lc_identifier(uri) }
            .compact
            .uniq
      end

      # returns the identifier if it is a valid LoC URI; returns nil otherwise
      def lc_identifier(uri)
        uri.match(%r{http://id\.loc\.gov/authorities/[a-z]*/([a-z0-9]*)})&.captures&.first
      end
    end
  end
end
