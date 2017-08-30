require 'test_helper'

class DataFieldHelperTest < ActionView::TestCase
  setup :create_solr_documents
  data_strings = YAML::load_file Rails.root.join('test', 'fixtures', 'data_strings.yml')

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
      link = external_link Hash[:value, 'http://library.linnbenton.edu/c.php?g=13287&p=2901925']
      assert is_valid_link link
    end
    test "external_link does not produce a link to any poorly-formatted URLs" do
      assert external_link(Hash[:value, 'abcderfghh']) !~ /<a\b[^>]*>(.*?)<\/a>/i
    end

  test "Snippet selects first element in array if snippet is array" do
    testarray = ["str1", "str2"]
    assert_equal("str1", snippet({value: testarray }))
  end


end
