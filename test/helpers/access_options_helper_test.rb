require 'test_helper'

class AccessOptionsHelperTest < ActionView::TestCase
  test "full text access link is parseable HTML" do
    assert Nokogiri::HTML.parse(display_fulltext_access_link('http://linnbenton.edu'))
  end
end
