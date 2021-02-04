# frozen_string_literal: true

# A few helpers for presenting Articles in the Show view
module ArticleShowHelper
  # Return an HTML <a> tag linking to a new search for the string included in options[:value]
  def link_to_article_author_search(options)
    to_sentence(Array.wrap(options[:value]).map do |value|
      link_to value, controller: 'articles', q: value, search_field: 'author'
    end)
  end

  # Return an HTML <a> tag linking to a new search for the string included in options[:value]
  def link_to_article_keyword_search(options)
    to_sentence(Array.wrap(options[:value]).map do |value|
      link_to value, controller: 'articles', q: value, search_field: 'all_fields'
    end)
  end
end
