require 'test_helper'

class RepresentativeImageHelperTest < ActionView::TestCase

  test "Article icon is a file and exists" do
    assert Rails.root.join('app', 'assets', 'images', format_icon_path('Article')).exist?
  end

  test "Representative Image Helper provides a link to the article icon" do
    article_doc = TestArticleDocument.new
    article_doc._source[:db] = 'test'
    article_doc._source[:id] = '123'
    assert is_valid_link (display_representative_image article_doc)
    
  end


end
