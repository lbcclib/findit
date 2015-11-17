module RepresentativeImageHelper
    require 'net/http'

    def display_representative_image(document, full_size=false )
       unless representative_image_path(document, 'L').nil?
          if full_size
             return link_to(image_tag(representative_image_path(document, 'M'), alt:document['title_t'], class: 'large-cover-image'), representative_image_path(document, 'L'))
          else
             return link_to(image_tag(representative_image_path(document, 'S'), alt:document['title_t'], class:(full_size ? 'large-cover-image' : 'thumbnail-cover-image')), :controller => "catalog", :action => "show", :id => document.id)
          end
       else
          return nil
       end
    end

    def get_image_url(isbn, size)
       full_url = URI.parse('http://covers.openlibrary.org/b/isbn/' + isbn + '-' + size + '.jpg?default=false')
       begin
          ol_test_response = Net::HTTP.get_response(full_url)
       rescue
          return false
       end
       if ol_test_response.code == '200'
          unless ol_test_response.body.include? 'not found'
             return full_url
	  end
       elsif ol_test_response.code == '302'
	       return ol_test_response['location']
       end
       return false
    end

    def representative_image_path(document, size='S')
       if document.has? 'isbn_t'
          isbns = []
          case document['isbn_t']
             when Array then isbns = document['isbn_t']
             when String then isbns.push(document['isbn_t'])
             else
                isbns = document['isbn_t'].to_a
          end
          isbns.each do |isbn|
             cover = CoverImage.find_by(isbn: isbn)
	     if cover
                if 'S' == size
                  return cover.thumbnail_url
		else
                  return cover.full_url
		end
             else
		thumbnail_url = get_image_url(isbn, 'S')
		if thumbnail_url
	           full_url = get_image_url(isbn, 'M')
		   image = CoverImage.create(isbn: isbn, thumbnail_url: thumbnail_url, full_url: full_url)
                   if 'S' == size
                     return thumbnail_url
		   else
                     return full_url
		   end
		end

             end
          end
       end
       if document.has? 'format'
          return 'icons/'.concat(document['format']).concat('.png')
       end
       return nil
    end
end
