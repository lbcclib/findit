module RepresentativeImageHelper
    # Generates HTML for either a cover image or format
    # icon, based on the requested side and identifiers from
    # the Solr document
    def display_representative_image(document, opts = {})
       if document.is_a? Article
           return image_tag(format_icon_path('Article'), alt:document['title'], class: 'thumbnail-cover-image')
       else
           cover_image = cover_image_url_for document
           if cover_image
               return image_tag(cover_image, alt:document['title_t'], class: 'thumbnail-cover-image')
           elsif document.has? 'format'
               return image_tag(format_icon_path(document['format']))
           else
               return ''
           end
       end
    end

    private

    # Returns a string with the path of a requested format icon
    #
    # Note that this method does not actually check if the
    # icon exists
    def format_icon_path format
        return 'icons/'.concat(format).concat('.png')
    end

end
