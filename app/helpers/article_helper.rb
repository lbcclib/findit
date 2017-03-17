# Helper functions for displaying journal/news articles
module ArticleHelper
    def display_article_type(original_string)
        article_type = original_string.capitalize
        unless article_type.include? 'article'
           article_type += ' article'
        end
        return article_type
    end

end
