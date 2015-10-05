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

    def check_image_source(isbn)
       base_url = 'http://covers.openlibrary.org/b/isbn/' + isbn
       thumbnail_url = URI.parse(base_url + '-S.jpg?default=false')
       ol_test_response = Net::HTTP.get_response(thumbnail_url)
       if ol_test_response.code == '302' or ol_test_response.code == '200'
          unless ol_test_response.body.include? 'not found'
             return true
	  end
       end
       return false
    end

    def download_to_file(uri, file_name, recurse = true)
	    response = Net::HTTP.get_response(URI(uri))
	    case response
	    when Net::HTTPSuccess then
		    open(file_name, 'wb') do |file|
			    file.write(response.body)
		    end
	    when Net::HTTPRedirection then
		    if recurse
		    	download_to_file(response['location'], file_name, false)
		    end
	    end
    end

    def download_images(isbn)
	    download_to_file('http://covers.openlibrary.org/b/isbn/' + isbn + '-S.jpg', 'app/assets/images/covers/' + isbn + '-S.jpg', true)
	    download_to_file('http://covers.openlibrary.org/b/isbn/' + isbn + '-M.jpg', 'app/assets/images/covers/' + isbn + '-M.jpg', true)
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
             unless Rails.application.assets.find_asset 'covers/' + isbn + '-S.jpg'
                if check_image_source(isbn)
                   download_images(isbn)
		end
             end
             if Rails.application.assets.find_asset 'covers/' + isbn + '-S.jpg'
                if 'S' == size
                  return 'covers/' + isbn + '-S.jpg'
		else
                  return 'covers/' + isbn + '-M.jpg'
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
