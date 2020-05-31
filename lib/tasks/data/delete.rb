# frozen_string_literal: true

require 'rsolr'

module FindIt
  module Data
    # Sends deletion requests to solr
    module Delete
      def by_record_provider_facet(facet_value)
        connection = RSolr.connect(Blacklight.connection_config.without(:adapter))
        connection.delete_by_query "record_provider_facet:\"#{facet_value}\""
        connection.commit
      end
    end
  end
end
