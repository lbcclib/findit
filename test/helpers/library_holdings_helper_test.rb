require 'test_helper'

# A class of tests for displaying availability data from the ILS
#
# Note that many of these rely on very specific titles from LBCC's collection
class LibraryHoldingsHelperTest < ActionView::TestCase

  setup :set_session_var

  test "can get status object for a TCN that exists" do
    assert_instance_of EvergreenHoldings::Status, get_status(346217)
  end

  test "get_status returns false if TCN doesn't have attached copies" do
    assert_not get_status(1)
  end

  private
  def set_session_var
      session[:evergreen_connection] = EvergreenHoldings::Connection.new 'http://libcat.linnbenton.edu'
  end

end
