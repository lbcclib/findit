require 'test_helper'

class DataFieldHelperTest < ActionView::TestCase
  puts Dir.pwd
  data_strings = YAML::load_file Rails.root.join('test', 'fixtures', 'data_strings.yml')

  test "Convert a string into an array" do
    assert_kind_of Array, field_to_array("A Magical String")
  end

  test "Convert an int into an array" do
    assert_kind_of Array, field_to_array(283)
  end

  test "Convert a Boolean into an array" do
    assert_kind_of Array, field_to_array(true)
  end

  test "Snippet produces text that is no longer than 200 characters using less than 200 characters" do
    assert snippet({Value: data_strings[:short_string]}).length <200
  end

    test "Snippet produces text that is no longer than 200 characters using exactly 200 characters" do
      assert snippet({Value: data_strings[:string_with_200_chars]}).length <200
    end

    test "Snippet produces text that is no longer than 200 characters using more than 200 characters" do
      assert snippet({Value: data_strings[:very_long_string]}).length <200
    end

    test "external link produces valid HTML link when given a well-formatted URL" do
      link = external_link 'http://library.linnbenton.edu/c.php?g=13287&p=2901925'
      assert Nokogiri::HTML.parse link
      assert !(link !~ /<a\b[^>]*>(.*?)<\/a>/i)
    end
    test "external_link does not produce a link to any poorly-formatted URLs" do
      assert external_link 'http://library.linnbenton.edu/c.php?g=13287&p=2901925' !~ /<a\b[^>]*>(.*?)<\/a>/i
    end
end
