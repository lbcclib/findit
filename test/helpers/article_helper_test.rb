require 'test_helper'

class ArticleHelperTest < ActionView::TestCase
  test "HTML Entities are cleaned up" do
    assert_equal "            <dt>Fun Fact::</dt>\n            <dd>100 is &lt; 200 &amp; 100 is &gt; 50</dd>\n", display_article_field("Fun Fact:","100 is &lt; 200 &amp; 100 is &gt; 50")
    # puts display_article_field("Fun Fact:","100 is &lt; 200 &amp; 100 is &gt; 50")
  end

  test "Broken HTML Entities are cleaned up" do
    assert_equal "            <dt>Fun Fact::</dt>\n            <dd>100 is &lt; 200 &amp&amp; 100 is &gt; 50</dd>\n", display_article_field("Fun Fact:","100 is &lt; 200 &amp&amp; 100 is &gt; 50")
  end

  test "Non Latin based languages are handled" do
    assert_equal "            <dt>パフ:</dt>\n            <dd>パフ、海のそばに住んでいた魔法のドラゴン</dd>\n", display_article_field("パフ","パフ、海のそばに住んでいた魔法のドラゴン")
  end
end
