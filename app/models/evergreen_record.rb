require 'evergreen_holdings'

class EvergreenRecord
  def initialize id, session
    if (session.key? 'evergreen_holdings_connection') && (session['evergreen_connection_timestamp'] > 2.hours.ago)
      @evergreen_connection = session['evergreen_holdings_connection']
    else
      begin
        @evergreen_connection = EvergreenHoldings::Connection.new 'http://libcat.linnbenton.edu'
        session['evergreen_holdings_connection'] = @evergreen_connection
        session['evergreen_connection_timestamp'] = Time.now
      rescue
      end
    end
    @record_id = id
  end

  def items_only_available_elsewhere?
    return (!self.on_shelf_at_lbcclib? && !self.on_shelf_at_lbcchoc? && self.status && self.status.any_copies_available?)
  end

  def on_shelf_at_lbcclib?
    self.on_shelf_at 7
  end

  def on_shelf_at_lbcchoc?
    self.on_shelf_at 9
  end

  def first_available_item_at library_id
    status = self.status
    if self.status
      status.libraries[library_id][:copies].each do |copy|
        if 'Available' == copy.status
          return copy
        end
      end
    end
    return nil
  end

  def status
    # Make sure we don't have the status ready to go
    if defined? @last_status
      @last_status
    else
      begin
        @last_status = @evergreen_connection.get_holdings @record_id
      rescue
        return nil
      end
    end
  end

  protected
  def on_shelf_at library_id
    return false if self.first_available_item_at(library_id).nil?
    true
  end

end

