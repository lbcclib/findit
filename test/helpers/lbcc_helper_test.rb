require 'test_helper'

class LbccHelperTest < ActionView::TestCase
  test "full text access link is parseable HTML" do
    assert Nokogiri::HTML.parse(display_fulltext_access_link('http://linnbenton.edu'))
  end

  test "Snippet produces text that is no longer than 200 characters using less than 200 characters" do
    assert snippet({value: "Something that is totally less than 200 characters"}).length <200
  end

    test "Snippet produces text that is no longer than 200 characters using exactly 200 characters" do
      assert snippet({Value: "A a s a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a"}).length <200
    end

    test "Snippet produces text that is no longer than 200 characters using more than 200 characters" do
      assert snippet({Value: "Time to write something that is incredibly poorly written but is for sure longer than 200 characters. It has to use all sorts of different letters and even some numbers. Maybe it can be about chickens. Maybe about dogs. All sorts of different ramblings. Ramblings that can fill books but won’t because they are filled with things that aren’t even close to interesting. Ramblings that are as painful as watching paint dry or watching grass grow. Ramblings that contain hardly any punctuation. "}).length <200
      #puts Value
    end
end
