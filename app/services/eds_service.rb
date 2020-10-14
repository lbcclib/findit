# frozen_string_literal: true

# Service that gets article metadata and searches
class EdsService
  def self.connect
    Rails.cache.fetch('eds-session', expires_in: 12.minutes) do
      ::EBSCO::EDS::Session.new
    end
  end
end
