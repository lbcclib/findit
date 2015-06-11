module DisplayHelper

require 'uri'

  def field_to_array(value)
      value_arr = []
      case value
          when Array then value_arr = value
          when String then value_arr.push(value)
          else
              value_arr = value.to_a
      end
   end

   def display_field(document, field_name, label, opts = {})

      if opts.key?(:dc_element)
         dc_property_string = opts[:dc_element].length > 0 ? 'property="http://purl.org/dc/terms/' + opts[:dc_element] + '"' : opts[:dc_element] 
      end


      if document.has? field_name
         values = field_to_array(document[field_name])
      else
         return nil
      end

      if opts[:search_link]
         search_field = opts.key?(:search_fields) ? opts[:search_fields] : 'all_fields'
         exact_match = opts.key?(:exact_match) ? opts[:exact_match] : false
         value_string = values.collect{ |value| search_catalog_link(strip(value), search_field, exact_match)}.join('; ')
      elsif opts[:contains_url]
         value_string = values.collect{ |url| external_link(url)}.join('; ')
      else
         value_string = values.collect{ |value| strip(value)}.join('; ')
      end

      if values.any?
         display_string  = <<-EOS
             <dt>#{label}:</dt>
             <dd #{dc_property_string}>#{value_string}</dd>
         EOS
         return display_string.html_safe
      end
   end


   def search_catalog_link(text, search_field, exact_match=false)
      if exact_match
         search_query = "\"#{text}\"".html_safe
      else
         search_query = text
      end
      return link_to text, catalog_index_path(:q => search_query, :search_field => search_field )
   end

   def external_link(url)
      if url =~ URI::regexp
         return link_to url, url
      end
   end


end
