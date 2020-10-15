# frozen_string_literal: true

# Service that gets article metadata and searches
class EdsService
  def self.connect
    Rails.cache.fetch('eds-session', expires_in: 12.minutes) do
      ::EBSCO::EDS::Session.new
    end
  end

  def self.eds_facets_from_param(param)
    selected_facets = param.blank? ? {} : param.to_unsafe_h
    criteria = ::EBSCO::EDS::SearchCriteria.new({ f: selected_facets }.with_indifferent_access, EdsService.connect.info)
    criteria.FacetFilters
  end
end
