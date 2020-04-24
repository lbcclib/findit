require 'traject'
require_relative 'cover_images.macro'
extend FindIt::Macros::CoverImages
require_relative 'lbcc_format.macro'
extend Traject::Macros::LbccFormats


to_field "thumbnail_path_ss", cover_image

to_field "id", extract_marc("001", :first => true)

ebook_providers = [
    'Wright American Fiction',
    'Brandeis University Press Open Access Ebooks',
    'All EBSCO eBooks',
    'Directory of Open Access Books',
    'Credo Academic Core',
    'NCBI Bookshelf',
]

needs_fod_url_changes = [
    'Films on Demand',
    'Films on Demand: Archival Films & Newsreels Collection - Academic',
    'Films on Demand: Master Career and Technical Education Collection - Academic',
]

needs_proxy = [
    'American History in Video United States',
    'Music Online: Classical Music Library - United States',
    'Music Online: Smithsonian Global Sound for Libraries',
]

streaming_music_providers = [
    'Music Online: Classical Music Library - United States',
    'Music Online: Smithsonian Global Sound for Libraries',
]

streaming_video_providers = [
    'Academic Video Online: Premium United States',
    'American History in Video United States',
    'Films on Demand',
    'Films on Demand: Archival Films & Newsreels Collection - Academic',
    'Films on Demand: Master Career and Technical Education Collection - Academic',
]

to_field 'record_provider_facet', literal('OCLC')
to_field 'record_source_facet', extract_marc('950a')
to_field 'is_electronic_facet', literal('Online')

to_field 'format' do |record, accumulator|
    db = record['950']['a'].to_s
    if ebook_providers.include? db
        accumulator << 'Ebook'
    elsif streaming_video_providers.include? db
        accumulator << 'Streaming video' 
    elsif streaming_music_providers.include? db
        accumulator << 'Streaming music' 
    else
        accumulator << Traject::Macros::LbccFormatClassifier.new(record).formats[0]
    end
    if accumulator.include? 'Book' #Make sure that nothing is marked as a book due to bad OCLC data
        accumulator.pop(accumulator.length)
        accumulator << 'Ebook'
    end
end

to_field 'url_fulltext_display' do |record, accumulator|
    db = record['950']['a'].to_s
    urls = record.find_all {|f| f.tag == '856'}
    urls.each do |field|
        value = field['u']
        if needs_proxy.include? db
            accumulator << "http://ezproxy.libweb.linnbenton.edu:2048/login?url=#{value}"
        elsif needs_fod_url_changes.include? db
            accumulator << value.sub(/(aid=|wid=\z)/, 'wID=102565').sub('portalPlaylists', 'PortalPlaylists')
        elsif 'Ebook Central Academic Complete' == db
            accumulator << value.sub('lib//detail.action', 'lib/linnbenton-ebooks/detail.action')
        else
            accumulator << value
        end
    end
end

