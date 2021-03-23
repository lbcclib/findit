# frozen_string_literal: true

require 'traject'
require_relative 'cover_images.macro'
extend FindIt::Macros::CoverImages
require_relative 'oclc_format.macro'

needs_proxy = [
  'American History in Video United States',
  'Music Online: Classical Music Library - United States',
  'Music Online: Smithsonian Global Sound for Libraries'
]

to_field 'thumbnail_path_ss', cover_image

to_field 'id', extract_marc('001', first: true)

to_field 'record_provider_facet', literal('OCLC')
to_field 'record_source_facet', extract_marc('950a')
to_field 'is_electronic_facet', literal('Online')

to_field 'format', FindIt::Macros::OCLCFormat.assign_format, default('Ebook')

to_field 'url_fulltext_display' do |record, accumulator|
  db = record['950']['a'].to_s
  urls = record.find_all { |f| f.tag == '856' }
  urls.each do |field|
    value = field['u']
    accumulator << if needs_proxy.include? db
                     "http://ezproxy.libweb.linnbenton.edu:2048/login?url=#{value}"
                   elsif db == 'Ebook Central Academic Complete'
                     value.sub('lib//detail.action', 'lib/linnbenton-ebooks/detail.action')
                   else
                     value
                   end
  end
end
