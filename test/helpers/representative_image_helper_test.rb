require 'test_helper'

class RepresentativeImageHelperTest < ActionView::TestCase

  test "Article icon is a file and exists" do
    assert Rails.root.join('app', 'assets', 'images', format_icon_path('Article')).exist?
  end


end
