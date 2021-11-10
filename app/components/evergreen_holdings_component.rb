# frozen_string_literal: true

# Display info about Evergreen Holdings in useful ways
class EvergreenHoldingsComponent < ViewComponent::Base
  def initialize(record_id:, size: :medium, service: nil)
    super
    @size = size
    @record_id = record_id
    service ||= EvergreenService.new
    @items = @size == :large ? service.best_items(@record_id) : Array(service.best_item(@record_id))
    @btn_class = @size == :small ? 'badge badge-success' : 'btn btn-success mt-1 d-inline-flex'
  end

  def url_for_evergreen_hold(tcn)
    'https://libcat.linnbenton.edu/eg/opac/place_hold?'\
      "query=locg=8;detail_record_view=1;hold_target=#{Array.wrap(tcn).first};hold_type=T"
  end

  def library_icon_for(item)
    item.location == 'LBCC Healthcare Occupations Center' ? 'local_hospital' : 'local_library'
  end

  def badge_class_for(status)
    status == 'Available' ? 'badge-success' : 'badge-danger'
  end

  def string_for(status)
    status == 'Available' ? 'obtain.available' : 'obtain.unavailable'
  end
end
