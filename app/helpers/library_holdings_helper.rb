module LibraryHoldingsHelper
    #require 'nokogiri'
    require 'open-uri'
    require 'uri'

    def display_library_holdings tcn, style
        if session[:evergreen_connection]
            stat = session[:evergreen_connection].get_holdings tcn, org_unit: 7
            if 'simple' == style
                if stat.any_copies_available?
                    display_library_holdings = '<a href="http://libcat.linnbenton.edu/eg/opac/record/' + tcn + '?locg=8;detail_record_view=1" target="_blank" class="btn btn-success">Available at the library</a>'
                    display_library_holdings.concat('<table class="table"><thead><tr><th>Status</th><th>Location</th><th>Call number</th></thead>')
                    stat.copies.first(5).each do |copy|
                        display_library_holdings.concat('<tr><td>' + copy[:status] + '</td>')
                        display_library_holdings.concat('<td>' + copy[:location] + '</td>')
                        display_library_holdings.concat('<td>' + copy[:call_number] + '</td></tr>')
                    end
                    display_library_holdings.concat('</table>')
                end
	    elsif 'fancy' == style
                display_library_holdings = '<h2>Find a copy on the shelf</h2>'
                stat.copies.each do |item|
                    display_library_holdings.concat('<dl class="dl-horizontal  dl-invert">')
                    display_library_holdings.concat('<dt>Status</dt><dd>' + item[:status] + '</dd>')
                    display_library_holdings.concat('<dt>Location</dt><dd>' + item[:location] + '</dd>')
                    display_library_holdings.concat('<dt>Call number</dt><dd>' + item[:call_number] + '</dd>')
                    display_library_holdings.concat('</dl>')
                    display_library_holdings.concat('<hr />')
                end
            end
        else
            return 'Ask a librarian for information about this item.'
        end
    end
    

=begin
    HOLDINGS_NS = 'http://open-ils.org/spec/holdings/v1'
    SUPERCAT_URI_PREFIX = 'http://libcat.linnbenton.edu/opac/extras/supercat/retrieve/atom-full/record/'

    def display_library_holdings(tcn, style)
        items = fetch_library_holdings(tcn)
        if false == items
            display_library_holdings = 'Ask a librarian for information about this item.'
	elsif 'fancy' == style
            display_library_holdings = '<h2>Find a copy on the shelf</h2>'


            items.each do |item|
                display_library_holdings.concat('<dl class="dl-horizontal  dl-invert">')
                display_library_holdings.concat('<dt>Status</dt><dd>' + item[:status] + '</dd>')
                display_library_holdings.concat('<dt>Location</dt><dd>' + item[:location] + '</dd>')
                display_library_holdings.concat('<dt>Call number</dt><dd>' + item[:label] + '</dd>')
                display_library_holdings.concat('</dl>')
                display_library_holdings.concat('<hr />')
            end
        elsif 'simple' == style
            some_item_available = false
            items.each do |item|
                if 'Available' == item[:status] then some_item_available = true end
            end
        if some_item_available
            display_library_holdings = '<a href="http://libcat.linnbenton.edu/eg/opac/record/' + tcn + '?locg=8;detail_record_view=1" target="_blank" class="btn btn-success">Available at the library</a>'
            display_library_holdings.concat('<table class="table"><thead><tr><th>Status</th><th>Location</th><th>Call number</th></thead>')
            items.first(5).each do |item|
                display_library_holdings.concat('<tr><td>' + item[:status] + '</td>')
                display_library_holdings.concat('<td>' + item[:location] + '</td>')
                display_library_holdings.concat('<td>' + item[:label] + '</td></tr>')
            end
            display_library_holdings.concat('</table>')
        else
            display_library_holdings = '<a href="http://libcat.linnbenton.edu/eg/opac/place_hold?query=locg=8;detail_record_view=1;hold_target=' + tcn + 'hold_type=T;hold_source_page=/eg/opac/record/'+ tcn + '?query=locg=8&detail_record_view=1" class="btn btn-warning" target="_blank">Place a hold</a>'
        end
    end

        return display_library_holdings.html_safe
    end


    def fetch_library_holdings(tcn)
    # Call number prefixes/suffixes need to be added
        copies = []
        begin
            @metadata = Nokogiri::XML(open(SUPERCAT_URI_PREFIX + tcn.to_s))
        rescue Errno::ECONNREFUSED
           return false
        rescue OpenURI::HTTPError
           return false
        end
        volumes = @metadata.xpath('//open-ils:volume[@opac_visible="t" and @deleted="f"][@lib="LBCCLIB"]', 'open-ils' => HOLDINGS_NS)
        volumes.each do |volume|
            label = volume.xpath('./@label').text
            items = volume.xpath('.//open-ils:copy[@opac_visible="t" and @deleted="f"]', 'open-ils' => HOLDINGS_NS)
            items.each do |item|
                tmp = {}
                tmp[:status] = item.xpath('.//open-ils:status', 'open-ils' => HOLDINGS_NS).text
                tmp[:location] = item.xpath('.//open-ils:location', 'open-ils' => HOLDINGS_NS).text
                tmp[:label] = label
                copies.push(tmp)
            end
        end
        return copies
    end
=end

end
