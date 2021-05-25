# frozen_string_literal: true

require 'bibtex'

module FindIt
  module Macros
    # A module for working with personal names
    module PersonalNames
      def self.to_direct_order
        lambda do |_rec, acc|
          acc.map! { |name| BibTeX::Name.parse(name)&.display_order || name }
        end
      end
    end
  end
end
