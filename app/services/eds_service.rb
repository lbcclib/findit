# frozen_string_literal: true

# Service that gets article metadata and searches
class EdsService
  def self.connect
    Rails.cache.fetch('eds-session', expires_in: 12.minutes) do
      ::EBSCO::EDS::Session.new
    end
  end

  def self.blacklight_style_search(params)
    connection = connect
    permitted_params = params.permit(:q, :page, :search_field, f: {})
    connection.search eds_style(permitted_params.to_h), false, false
  end

  def self.eds_style(params)
    # EDS gem doesn't understand the all_fields search_field
    params['search_field'] = 'KW' if params['search_field'] == 'all_fields'

    # EDS defaults to 20 pages, which is more than we want
    params['results_per_page'] ||= 10
    params.with_indifferent_access
  end
end
