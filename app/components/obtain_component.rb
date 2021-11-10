# frozen_string_literal: true

# A view component that provides options for accessing a resource
class ObtainComponent < ViewComponent::Base
  def initialize(document:, evergreen_service:, size: :medium)
    @size = size
    @document = document
    @evergreen_service = evergreen_service
    @record_id = @document.first :id
  end

  private

  def online_record?
    @document.has? 'url_fulltext_display'
  end

  def evergreen_record?
    @document.has? 'eg_tcn_t'
  end
end
