require 'test_helper'
require Rails.root.join('app', 'helpers', 'data_field_helper').to_s
include DataFieldHelper

class ArticleHelperTest < ActionView::TestCase
    test "Article type is a string" do
        assert_kind_of String, display_article_type('Journal')
    end
end
