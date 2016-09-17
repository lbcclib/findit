module RepresentativeImageHelper
    require 'net/http'

    # Generates HTML for either a cover image or format
    # icon, based on the requested side and identifiers from
    # the Solr document
    def display_representative_image(document, full_size=0 )
       unless representative_image_path(document, 'S').nil?
             return link_to(image_tag(representative_image_path(document, 'S'), alt:document['title_t'], class:(full_size ? 'large-cover-image' : 'thumbnail-cover-image')), :controller => "catalog", :action => "show", :id => document.id)
       else
          return nil
       end
    end

    # Returns a URL for an image from the Open Library.
    # identifier_type can be ISBN, OCLC, or LCCN (case-
    # insensitive).
    def get_image_url(identifier, identifier_type, size)
        begin
            full_url = URI.parse('http://covers.openlibrary.org/b/' + identifier_type + '/' + identifier + '-' + size + '.jpg?default=false')
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

    # Returns a path for a format icon
    def format_icon_path format
        return 'icons/'.concat(format).concat('.png')
    end

    # Returns a URL or path for either an image
    # or format icon
    def representative_image_path(document, size='S')
        cover = CoverImage.find_by(solr_id: document.id)
        if cover
            if cover.updated_at.to_i > 2.weeks.ago.to_i
                if cover.thumbnail_url
                #if an image url is cached, just return it
                    if 'S' == size
                        return cover.thumbnail_url
                    else
                        return cover.full_url
		    end
                end

            elsif document.has? 'isbn_t'
            #Search again if the cache is too old
                isbns = find_isbns_from(document)
                isbns.each do |isbn|
	            thumbnail_url = get_image_url(isbn, 'isbn', 'S')
	            if thumbnail_url
	                 full_url = get_image_url(isbn, 'isbn', 'M')
	                 image = CoverImage.update(cover.id, isbn: isbn, thumbnail_url: thumbnail_url, full_url: full_url, solr_id: document.id)
                         if 'S' == size
                             return thumbnail_url
		         else
                             return full_url
		         end
                    end
                end
            end

        # If the image has not yet been cached
        elsif document.has? 'isbn_t'
            isbns = find_isbns_from(document)
            isbns.each do |isbn|
                thumbnail_url = get_image_url(isbn, 'isbn', 'S')
	        if thumbnail_url
	            full_url = get_image_url(isbn, 'isbn', 'M')
		    image = CoverImage.create(isbn: isbn, thumbnail_url: thumbnail_url, full_url: full_url, solr_id: document.id)
                    if 'S' == size
                        return thumbnail_url
		    else
                        return full_url
		    end
                end
            end
        end
        image = CoverImage.create(solr_id: document.id)
        if document.has? 'format'
            return format_icon_path document['format']
        end
        return nil
    end

    # Returns an array of all the ISBNs in the given solr document
    def find_isbns_from(document)
        isbns = []
        case document['isbn_t']
            when Array then isbns = document['isbn_t']
            when String then isbns.push(document['isbn_t'])
        else
            isbns = document['isbn_t'].to_a
        end
	    return isbns
    end
end
