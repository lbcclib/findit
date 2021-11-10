# frozen_string_literal: true

# Some shared code focused on helping patrons obtain
# the resources they've found
module ObtainHelper
  def evergreen_record?(document)
    document.has? 'eg_tcn_t'
  end

  def online_record?(document)
    document.has? 'url_fulltext_display'
  end

  def url_for_evergreen_hold(tcn)
    'https://libcat.linnbenton.edu/eg/opac/place_hold?'\
      "query=locg=8;detail_record_view=1;hold_target=#{Array.wrap(tcn).first};hold_type=T"
  end
end
