# frozen_string_literal: true

class ObtainOnlineComponent < ViewComponent::Base
  attr_reader :string

  def initialize(document:, size: :medium)
    @size = size
    @document = document
    @url = document_url
    @string = display_string
    super
  end

  private

  def display_string
    return t('obtain.resource') if document_format.blank?

    return t(format_i18n_string) if format_i18n_string

    t('obtain.general_online', type: document_format)
  end

  def document_format
    @document.first 'format'
  end

  def document_url
    @document.first 'url_fulltext_display'
  end

  def format_i18n_string
    raw_format = document_format
    key = "obtain.#{raw_format.downcase.sub(' ', '_')}"

    return nil unless I18n.exists? key

    key
  end
end
