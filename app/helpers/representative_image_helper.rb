module RepresentativeImageHelper
    require 'net/http'

    def display_representative_image(document, full_size=false )
       unless representative_image_url(document, 'L').nil?
          if full_size
             return link_to(image_tag(representative_image_url(document, 'M'), alt:document['title_t'], class: 'large-cover-image'), representative_image_url(document, 'L'))
          else
             return link_to(image_tag(representative_image_url(document, 'S'), alt:document['title_t'], class:(full_size ? 'large-cover-image' : 'thumbnail-cover-image')), :controller => "catalog", :action => "show", :id => document.id)
          end
       else
          return nil
       end
    end

    def representative_image_url(document, size='S')
       if document.has? 'isbn_t'
          isbns = []
          case document['isbn_t']
             when Array then isbns = document['isbn_t']
             when String then isbns.push(document['isbn_t'])
             else
                isbns = document['isbn_t'].to_a
          end
          isbns.each do |isbn|
             base_url = 'http://covers.openlibrary.org/b/isbn/' + isbn
             thumbnail_url = URI.parse(base_url + '-S.jpg?default=false')
             ol_test_response = Net::HTTP.get_response(thumbnail_url)
             if ol_test_response.code == '302'
                unless ol_test_response.body.include? 'not found'
                   if 'S' == size
                      return base_url + '-S.jpg'
                   else
                      return base_url + '-M.jpg'
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
