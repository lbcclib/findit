class EdsService
  def self.get_valid_connection session
    if (session.key? 'eds_session_token') && (session.key? 'eds_session_timestamp') && (session['eds_session_timestamp'] > 20.minutes.ago)
      ::EBSCO::EDS::Session.new session['eds_session_token']
    else
      ses = ::EBSCO::EDS::Session.new
      session['eds_session_token'] = ses.session_token
      session['eds_session_timestamp'] = Time.now
      ses
    end
  end
end
