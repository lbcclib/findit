# frozen_string_literal: true

class ObtainOnlineComponent < ViewComponent::Base
  def initialize(size: :medium, document:)
    @size = size
    @document = document
    @url = document_url
    @string = display_string
    super
  end

  private

  def display_string
    return t(format_i18n_string) if I18n.exists? format_i18n_string

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
    "obtain.#{raw_format.downcase.sub(' ', '_')}"
  end


end
