# These helpers help with extracting and formatting
# data about Solr documents and Article API data
module DataFieldHelper

    include ActionView::Helpers::TextHelper
    require 'uri'


    # Create the HTML to display a field
    # from a solr document
    def display_field(document, field_name, label, opts = {})
        
        # Make sure that the document actually has the
        # desired field
        if document.respond_to? field_name
           if document.send field_name
              values = turn_into_array(document.send field_name)
           else
              return nil
           end
        elsif document.has? field_name
           values = turn_into_array(document[field_name])
        else
           return nil
        end
        
        if opts[:dedupe]
           if :personal_names == opts[:dedupe]
              values.uniq! { |s| s.gsub(/\s?--\s*$/, '').gsub(/^(.*),\s([A-Z]).*\z/, '\2 \1').gsub(/^([a-zA-Z]).*\s([a-zA-z]*)[,\(-\z]/, '\1 \2') }
           end
        end

	return array_to_html_for_display values, label, opts
    end

    # Returns an HTML link to a search for the query "text" in quotes
    def exact_search_catalog_link text, search_field
        return link_to text, url_for(:q => "\"#{text}\"", :search_field => search_field )
    end

    # Returns an HTML link to a search for the "text" query
    def search_catalog_link text, search_field
        return link_to text, url_for(:q => text, :search_field => search_field )
    end

    # Return an HTML <a> tag containing a URL both as its content and its href attribute
    def external_link(url)
        if url =~ URI::regexp
            return link_to url, url
        else
            return url
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

    # Takes any possible output from solr and turns it into an array
    def turn_into_array(value)
        value_arr = []
        if value.is_a?(Array)
           value_arr = value
        elsif value.is_a?(String)
           if value.length>0
              value_arr.push(value)
           end
        else
            value_arr.push value.to_s
        end
        return value_arr
    end

    # Takes an array of values and outputs a valid HTML display of the array
    def array_to_html_for_display values, label, opts
        values_html = Array.new

        values.each do |value|
           # Display this field as a link to a search
           if opts[:search_link]
              # If no search field is specified, default to
              # searching all fields
              search_field = opts.key?(:search_fields) ? opts[:search_fields] : 'all_fields'
              if opts.key?(:exact_match)
                 value_string = exact_search_catalog_link(strip(value), search_field)
              else
                 value_string = search_catalog_link(strip(value), search_field)
              end

           elsif opts[:contains_url]
              value_string = external_link(value) 

           else
              value_string = value
           end
           if opts[:snippet]
              value_string = snippet :value => value_string
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

end
