require 'test_helper'

class DataFieldHelperTest < ActionView::TestCase
  puts Dir.pwd
  data_strings = YAML::load_file Rails.root.join('test', 'fixtures', 'data_strings.yml')

  test "Snippet produces text that is no longer than 200 characters using less than 200 characters" do
    assert snippet({Value: data_strings[:short_string]}).length <200
  end

    test "Snippet produces text that is no longer than 200 characters using exactly 200 characters" do
      assert snippet({Value: data_strings[:string_with_200_chars]}).length <200
    end

    test "Snippet produces text that is no longer than 200 characters using more than 200 characters" do
      assert snippet({Value: data_strings[:very_long_string]}).length <200
      #puts Value
    end
end
