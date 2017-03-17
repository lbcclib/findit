require 'test_helper'


class ArticleSearchTest < ActiveSupport::TestCase

  test "Article Search search_opts method returns an array" do
    a = ArticleSearch.new 'soap opera', 3, [], nil
    assert_instance_of Array, a.search_opts
  end

end
