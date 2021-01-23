# frozen_string_literal: true

# Service that gets article metadata and searches
class EdsService
  def self.connect(force_new_session = false)
    ses = Rails.cache.fetch('eds-session', expires_in: 12.minutes, force: force_new_session) do
      ::EBSCO::EDS::Session.new max_attempts: 10
    end
    Rails.logger.info ses.inspect
    ses
  end

  def self.search(params, force_new_session = false)
    connection = connect
    connection.search params, false, false
  rescue EBSCO::EDS::ApiError, EBSCO::EDS::BadRequest
    self.search params, true
  end

  def self.retrieve(dbid, an, force_new_session = false)
    connection = connect
    connection.retrieve dbid: dbid, an: an
  rescue EBSCO::EDS::ApiError, EBSCO::EDS::BadRequest
    self.retrieve dbid, an
  end

  def self.blacklight_style_search(params)
    permitted_params = params.permit(safe_params)
    search eds_style(permitted_params.to_h)
  end

  def self.eds_style(params)
    # EDS defaults to 20 pages, which is more than we want
    params['results_per_page'] ||= 10
    params['highlight'] = false
    params.with_indifferent_access
  end

  def self.safe_params
    [:q, :page, :search_field, :db, :highlight, :view, { range: {}, f: {} }]
  end
end
