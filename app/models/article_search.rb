class ArticleSearch
  def self.send connection, search_opts
    opts = self.search_opts search_opts
    connection.search opts, false, false
  end

  protected

  # Assemble the requested filters, search options, and defaults for an article search
  def self.search_opts opts = {}
    requested_facets = opts[:requested_facets] || {}
    search_field = opts[:search_field] || 'all_fields'
    search_field_code = opts[:search_field_code] || 'AND'
    page = opts[:page] || 1
    q = opts[:q] || 'Linn-Benton Community College'
    num_rows = opts[:num_rows] || '10'

    i = 1
    facet_filters = Array.new
    requested_facets.each do |key, values|
      values.each do |value|
        facet_filters << {'FilterId' => i, 'FacetValues' => [{'Id' => key.gsub(/\s+/, ''), 'Value' => value}]}
        i = i + 1
      end
    end
    return {:query => search_field_code + ':' + q,
      'page' => page,
      :results_per_page => num_rows,
      :limiters => ['FT:y'],
      :facet_filters => facet_filters
    }
  end

end
