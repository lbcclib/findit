# These helpers help with extracting and formatting
# data about Solr documents and Article API data
module DataFieldHelper

    include ActionView::Helpers::TextHelper
    require 'uri'


    # Return an HTML <a> tag containing a URL both as its content and its href attribute
    def external_link(options)
        if options[:value].is_a? Array
            options[:value] = options[:value].first
        end
        if options[:value] =~ URI::regexp
            return link_to options[:value], options[:value]
        else
            return options[:value]
        end
    end

    # Return an HTML <a> tag linking to a new search for the string included in options[:value]
    def link_to_article_search(options)
	    return Array.wrap(options[:value]).map{|value| link_to value, controller: 'catalog', q: value, show_articles: true}.to_sentence.html_safe
    end

    # Provides a shortened version of strings.  This is used to cut down particularly
    # wordy abstracts to display on search results pages.
    # Defaults to producing snippets that are 200 characters or less, but supports an
    # option called +:length+ which provides a different number of characters.
    #
    #   snippet :value => "My very short string" # => "My very short string" 
    #   snippet :value => "My very short string", :length => 8 # => "My very" 
    def snippet opts={}
        desired_length = opts[:length] || 200
        if opts[:value].is_a? Array
	    value = opts[:value][0]
        else
	    value = opts[:value]
        end
        return truncate strip(sanitize value), length: desired_length, separator: ' '
    end

    private

    # Remove whitespace and punctuation marks from the beginning and end
    # of a string
    def strip(string)
        # Also strip preceeding [ or whitespace
	if !string.is_a? String
	   string = string.to_s
	end
        string.gsub!(/^[\*\s]*/, '')
        string.gsub!(/[,\:;\s]*$/, '')
        return string
    end

end
