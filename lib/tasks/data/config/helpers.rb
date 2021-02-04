# frozen_string_literal: true

module FindIt
  # Logic shared across the indexing code
  module Data
    def online_resource?(record)
      format_field = record['008']&.value
      format_field && (format_field[23] == 'o')
    end
  end
end
