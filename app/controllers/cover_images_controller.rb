# A controller that fetches cover images from OpenLibrary and
# caches them using the ActiveRecord model
module CoverImagesController
    require 'net/http'

    # Returns a URL if it can find a cover image for the document
    # Otherwise returns false
    def cover_image_url_for document
        cover = CoverImage.find_by(solr_id: document.id)
        identifiers = find_identifiers_from document

        if cover
            if recent_enough? cover.updated_at
                if cover.thumbnail_url
                    return cover.thumbnail_url
                end
            else
                updated = update_cache identifiers, cover
                return updated if updated
            end
        else
            # If the image has not yet been cached
            new_cover = fetch_new_cover identifiers, document.id
            return new_cover if new_cover
        end
        return false
    end

    private

    # Extracts an array of a given type of identifier from the 
    # solr document
    def extract_identifiers document, solr_label
        identifiers = []
        if document.has? solr_label
            case document[solr_label]
                when Array then identifiers = document[solr_label]
                when String then identifiers.push(document[solr_label])
            else
                identifiers = document[solr_label].to_a
            end
        end
        return identifiers
    end

    # Returns a URI for a thumbnail image if it can find one,
    # otherwise it returns false
    # If it was successful, it also caches the URI
    def fetch_new_cover identifiers, id
        identifiers[:isbns].each do |isbn|
            thumbnail_url = get_image_url(isbn, 'isbn', 'S')
            if thumbnail_url
                full_url = get_image_url(isbn, 'isbn', 'M')
                image = CoverImage.create(isbn: isbn, thumbnail_url: thumbnail_url, full_url: full_url, solr_id: id)
                if image.valid?
                    return thumbnail_url
		end
            end
        end
        image = CoverImage.create(solr_id: id)
        return false
    end

    # Creates a hash containing three arrays of identifiers
    # for ISBNs, OCLC numbers, and LCCNs
    def find_identifiers_from document
        identifiers = { isbns: extract_identifiers(document, 'isbn_t'),
            oclcns: extract_identifiers(document, 'oclcn_t'),
            lccns: extract_identifiers(document, 'lccn_t') }
        return identifiers
    end

    # Returns a URI object for an image from the Open Library.
    # identifier_type can be ISBN, OCLC, or LCCN (case-
    # insensitive).
    #
    # Returns a URL if successful, false if not
    def get_image_url identifier, identifier_type, size
        begin
            return URI.parse('https://covers.openlibrary.org/b/' + identifier_type + '/' + identifier + '-' + size + '.jpg?default=false')
        rescue
            return false
        end
    end

    # Check to make sure the cache isn't older than 3 weeks
    def recent_enough? updated_at
        return 3.weeks.ago.to_i < updated_at.to_time.to_i
    end


    # Search for cover images for an existing solr id
    # and update the cache accordingly
    #
    # Returns a thumbnail URL if an image was found, false if not
    def update_cache identifiers, cover
        identifiers[:isbns].each do |isbn|
            thumbnail_url = get_image_url(isbn, 'isbn', 'S')
            if thumbnail_url
                 full_url = get_image_url(isbn, 'isbn', 'M')
                 cover.update(isbn: isbn, thumbnail_url: thumbnail_url, full_url: full_url)
                 return thumbnail_url
            end
        end
        return false
    end

end
