require 'evergreen_holdings'

class EvergreenRecord
  def initialize id, session
    if (session.key? 'evergreen_holdings_connection') && (session['evergreen_connection_timestamp'] > 2.hours.ago)
      @evergreen_connection = session['evergreen_holdings_connection']
    else
      @evergreen_connection = EvergreenHoldings::Connection.new 'http://libcat.linnbenton.edu'
      session['evergreen_holdings_connection'] = @evergreen_connection
      session['evergreen_connection_timestamp'] = Time.now
    end
    @record_id = id
  end

  def on_shelf_at_lbcclib?
    self.on_shelf_at 7
  end

  def on_shelf_at_lbcchoc? id
    self.on_shelf_at 9
  end

  def status
    # Make sure we don't have the status ready to go
    if defined? @last_status
      @last_status
    else
      @last_status = @evergreen_connection.get_holdings @record_id
    end
  end

  protected
  def on_shelf_at library_id
    status = self.status
    status.libraries[library_id][:copies].each do |copy|
      if 'Available' == copy.status
        return true
      end
    end
    return false
  end

end
