# frozen_string_literal: true

# Override the default Spellcheck component to add collated spellcheck suggestions
class FinditSpellcheckComponent < Blacklight::Response::SpellcheckComponent
  # @param [Blacklight::Response] response
  # @param [Array<String>] options explicit spellcheck options to render
  def initialize(response:, options: nil)
    super
    @options.unshift(@response&.spelling&.collation)
  end
end
