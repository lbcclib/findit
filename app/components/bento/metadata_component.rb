# frozen_string_literal: true

module Bento
  # Display a bespoke list of metadata field in bento search results view
  class MetadataComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super
    end
  end
end
