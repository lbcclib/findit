module ArticleShowHelper
    # Return an HTML <a> tag linking to a new search for the string included in options[:value]
    def link_to_article_author_search(options)
        return Array.wrap(options[:value]).map{|value| link_to value, controller: 'articles', q: value, search_field: 'author'}.to_sentence.html_safe
    end

    # Return an HTML <a> tag linking to a new search for the string included in options[:value]
    def link_to_article_keyword_search(options)
        return Array.wrap(options[:value]).map{|value| link_to value, controller: 'articles', q: value, search_field: 'all_fields'}.to_sentence.html_safe
    end
end
