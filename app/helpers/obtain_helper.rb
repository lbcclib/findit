module ObtainHelper
  def is_evergreen_record?(document)
    document.has? 'eg_tcn_t'
  end

  def is_online_record?(document)
    document.has? 'url_fulltext_display'
  end

  def url_for_evergreen_hold(tcn)
    'https://libcat.linnbenton.edu/eg/opac/place_hold?query=locg=8;detail_record_view=1;hold_target=' + Array.wrap(tcn).first.to_s + ';hold_type=T'
  end
end
