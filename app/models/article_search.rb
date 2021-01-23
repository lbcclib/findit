# frozen_string_literal: true

# This model represents a search in the external
# API for articles
class ArticleSearch
  def self.send(search_opts)
    opts = self.search_opts search_opts
    EdsService.search opts
  end

  # Assemble the requested filters, search options, and defaults for an article search
  def self.search_opts(opts = {})
    requested_facets = opts[:f] || {}
    search_field = opts[:search_field] || 'all_fields'
    search_field_code = opts[:search_field_code] || ''
    page = opts[:page] || 1
    q = opts[:q] || 'Linn-Benton Community College'
    num_rows = opts[:num_rows] || '10'

    { :query => search_field_code + q,
      'page' => page,
      :results_per_page => num_rows,
      :limiters => ['FT:y'],
      :view => opts[:view] || 'detailed',
      :include_facets => opts[:include_facets] || true,
      :facet_filters => requested_facets }
  end
end
