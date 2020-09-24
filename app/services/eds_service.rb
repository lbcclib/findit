# frozen_string_literal: true

# Service that gets article metadata and searches
class EdsService
  def self.get_valid_connection(session)
    if self.valid_connection_exists session
      ::EBSCO::EDS::Session.new session_token: session['eds_session_token']
    else
      ses = ::EBSCO::EDS::Session.new
      session['eds_session_token'] = ses.session_token
      session['eds_session_timestamp'] = Time.now
      ses
    end
  end

  def self.valid_connection_exists(session)
    (session.key? 'eds_session_token') &&
      (session.key? 'eds_session_timestamp') &&
      (session['eds_session_timestamp'] > 15.minutes.ago)
  end
end
