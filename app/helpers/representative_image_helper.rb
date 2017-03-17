module RepresentativeImageHelper
    # Generates HTML for either a cover image or format
    # icon, based on the requested side and identifiers from
    # the Solr document
    def display_representative_image(document, opts = {})
       if document.is_a? Article
           return link_to(image_tag(format_icon_path('Article')), controller: 'articles', action: 'show', db: url_encode(document[:db]), id: url_encode(document[:id]))
       else
           cover_image = cover_image_url_for document
           if cover_image
               return link_to(image_tag(cover_image, alt:document['title_t'], class: 'thumbnail-cover-image'), :controller => "catalog", :action => "show", :id => document[:id])
           elsif document.has? 'format'
               return link_to(image_tag(format_icon_path(document['format']), alt:document['title_t'], class: 'thumbnail-cover-image'), :controller => 'catalog', :action => 'show', :id => document.id)
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
