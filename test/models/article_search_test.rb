require 'test_helper'


class ArticleSearchTest < ActiveSupport::TestCase
    test "can initialize" do
        as = ArticleSearch.new 'cat', 'author', 2, [], EdsConnection.new
    end
    

end
