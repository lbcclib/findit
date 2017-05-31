require 'test_helper'

class DataFieldHelperTest < ActionView::TestCase
  data_strings = YAML::load_file Rails.root.join('test', 'fixtures', 'data_strings.yml')

  test "turn_into_array converts a string into an array" do
    assert_kind_of Array, turn_into_array("A Magical String")
  end

  test "turn_into_array converts an int into an array" do
    assert_kind_of Array, turn_into_array(283)
  end

  test "turn_into_array converts a Boolean into an array" do
    assert_kind_of Array, turn_into_array(true)
  end

  test "turn_into_array keeps arrays as they are" do
    assert_kind_of Array, turn_into_array(["cats", "dogs", "goats", "iguanas"])
  end

  test "Snippet produces text that is no longer than 200 characters using less than 200 characters" do
    assert snippet({value: data_strings[:short_string]}).length <200
  end

    test "Snippet produces text that is no longer than 200 characters using exactly 200 characters" do
      assert snippet({value: data_strings[:string_with_200_chars]}).length <200
    end

    test "Snippet produces text that is no longer than 200 characters using more than 200 characters" do
      assert snippet({value: data_strings[:very_long_string]}).length <200
    end

    test "external link produces valid HTML link when given a well-formatted URL" do
      link = external_link 'http://library.linnbenton.edu/c.php?g=13287&p=2901925'
      assert is_valid_link link
    end
    test "external_link does not produce a link to any poorly-formatted URLs" do
      assert external_link 'http://library.linnbenton.edu/c.php?g=13287&p=2901925' !~ /<a\b[^>]*>(.*?)<\/a>/i
    end

    test "check that short document has a field_name" do
      assert get_array_from_solr @short_document, :title_display
    end
   
    test "check that long document has a field_name" do
      assert get_array_from_solr @long_document, :author_display
    end
    
    test "check that long document does not have a field_name" do
      assert !(get_array_from_solr @long_document, :url_fulltext_display)
    end

  test "Snippet selects first element in array if snippet is array" do
    testarray = ["str1", "str2"]
    assert_equal("str1", snippet({value: testarray }))
  end


end
