# frozen_string_literal: true

unless Rails.env == 'indexer'
  Blacklight::LocalePicker::Engine.config.available_locales = %w[en es]
end