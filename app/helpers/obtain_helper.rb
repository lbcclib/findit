module ObtainHelper
  def is_evergreen_record? document
    return document.has? 'eg_tcn_t'
  end
  def is_online_record? document
    return document.has? 'url_fulltext_display'
  end
end
