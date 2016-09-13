module DataFieldHelper

    include ActionView::Helpers::TextHelper
    require 'uri'

    # Make sure that this is an array
    def field_to_array(value)
        value_arr = []
        if value.is_a?(Array)
           value_arr = value
        elsif value.is_a?(String)
           if value.length>0
              value_arr.push(value)
           end
        else
            value_arr = value.to_a
        end
        return value_arr
    end

    # Create the HTML to display a field
    # from a solr document
    def display_field(document, field_name, label, opts = {})
        
        # Make sure that the document actually has the
        # desired field
        if document.respond_to? field_name
           if document.send field_name
              values = field_to_array(document.send field_name)
           else
              return nil
           end
        elsif document.has? field_name
           values = field_to_array(document[field_name])
        else
           return nil
        end

        values_html = Array.new

        values.each do |value|
           # Display this field as a link to a search
           if opts[:search_link]
              # If no search field is specified, default to
              # searching all fields
              search_field = opts.key?(:search_fields) ? opts[:search_fields] : 'all_fields'
              exact_match = opts.key?(:exact_match) ? opts[:exact_match] : false
              value_string = search_catalog_link(strip(value), search_field, exact_match)

           elsif opts[:contains_url]
              value_string = external_link(value) 

           else
              value_string = value
           end

           # Add a DC RDFa attribute
           if opts.key?(:dc_element)
              entry = opts[:dc_element].length > 0 ? '<span property="http://purl.org/dc/terms/' + opts[:dc_element] + '">' + value_string + '</span>' : value_string
           else
              entry = value_string
           end
        values_html.push(entry)
        end

        if values_html.any?
           display_string = '<dt>' + label + '</dt><dd>' + values_html.join('; ')
           return display_string.html_safe
        end
    end

    def search_catalog_link(text, search_field, exact_match=false)
        if exact_match
            search_query = "\"#{text}\"".html_safe
        else
            search_query = text
        end
        return link_to text, url_for(:q => search_query, :search_field => search_field )
    end

    def external_link(url)
        if url =~ URI::regexp
            return link_to url, url
        end
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
        return truncate strip(value), length: desired_length, separator: ' '
    end

    def strip(string)
        # Also strip preceeding [ or whitespace
	if !string.is_a? String
	   string = string.to_s
	end
        string.gsub!(/^[\*\s]*/, '')
        string.gsub!(/[,\-:;\s]*$/, '')
        return string
    end

end
