require 'traject'

to_field 'url_fulltext_display' do |record, accumulator|
    urls = record.find_all {|f| f.tag == '856'}
    urls.each do |field|
        value = field['u']
        accumulator << "http://ezproxy.libweb.linnbenton.edu:2048/login?url=#{value}"
    end
end

