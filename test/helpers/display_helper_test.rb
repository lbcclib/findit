require 'test_helper'

class DisplayHelperTest < ActionView::TestCase
  test "Convert a string into an array" do
    assert_kind_of Array, field_to_array("A Magical String")
  end

  test "Convert an int into an array" do
    assert_kind_of Array, field_to_array(283)
  end

  test "Convert a Boolean into an array" do
    assert_kind_of Array, field_to_array(True)
  end
end
