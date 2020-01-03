class EdsService
  def self.get_valid_connection session
    if (session.key? 'eds_session_token') && (session.key? 'eds_session_timestamp') && (session['eds_session_timestamp'] > 15.minutes.ago)
	    puts "IN HERE BUT NOT SUPPOSED TO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      ::EBSCO::EDS::Session.new session_token: session['eds_session_token']
    else
	    puts "&&&&&&&&&&&&&&&&&&&&&&&&&&"
	    puts "&&&&&&&&&&&&&&&&&&&&&&&&&&"
	    puts "&&&&&&&&&&&&&&&&&&&&&&&&&&"
	    puts "&&&&&&&&&&&&&&&&&&&&&&&&&&"
	    puts "GAVE ME BAD"
	    puts "&&&&&&&&&&&&&&&&&&&&&&&&&&"
	    puts "&&&&&&&&&&&&&&&&&&&&&&&&&&"
	    puts "&&&&&&&&&&&&&&&&&&&&&&&&&&"
      ses = ::EBSCO::EDS::Session.new
      session['eds_session_token'] = ses.session_token
      session['eds_session_timestamp'] = Time.now
      ses
    end
  end
end
