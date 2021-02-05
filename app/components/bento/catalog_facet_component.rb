# frozen_string_literal: true

module Bento
  # Display a fake "facet" in the bento views
  class CatalogFacetComponent < ViewComponent::Base
    def initialize(facet_key:, label:, catalog_format_facets:)
      @facet_key = facet_key
      @label = label
      @catalog_format_facets = catalog_format_facets
      super
    end
  end
end
