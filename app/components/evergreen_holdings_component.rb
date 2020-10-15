# frozen_string_literal: true

# Display info about Evergreen Holdings in useful ways
class EvergreenHoldingsComponent < ViewComponent::Base
  def initialize(size: :medium, record_id:)
    @size = size
    @record_id = record_id
    service = EvergreenService.new
    @items = service.best_item @record_id
    @btn_class = @size == :small ? 'badge badge-success' : 'btn btn-success mt-1'
  end

  def url_for_evergreen_hold(tcn)
    'https://libcat.linnbenton.edu/eg/opac/place_hold?query=locg=8;detail_record_view=1;hold_target=' +
      Array.wrap(tcn).first.to_s + ';hold_type=T'
  end

  def library_icon_for(item)
    item.location == 'LBCC Healthcare Occupations Center' ? 'local_hospital' : 'local_library'
  end
end
