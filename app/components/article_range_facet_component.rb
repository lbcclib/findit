# frozen_string_literal: true

# Display info about Evergreen Holdings in useful ways
class ArticleRangeFacetComponent < ::Blacklight::FacetFieldListComponent
  def initialize(**)
    super
    @this_year = Time.zone.now.year
    @five_years_ago = @this_year - 5
    @hits_in_last_five = @facet_field.display_facet.items
                                     .select { |f| (@five_years_ago..@this_year).cover? f.value.to_i }.sum(&:hits)
  end
end
