# frozen_string_literal: true

require 'traject'

to_field 'id', extract_marc('001', first: true)

to_field 'record_provider_facet', literal('Gale Article Databases')
to_field 'record_source_facet' do |record, accumulator|
  gale_id = record['001']
  if gale_id.to_s.include? 'OVIC'
    accumulator << 'Opposing Viewpoints in Context'
  elsif gale_id.to_s.include? 'UHIC'
    accumulator << 'U.S. History In Context'
  elsif gale_id.to_s.include? 'ocm'
    accumulator << 'National Geographic Magazine Archive'
  end
end
to_field 'is_electronic_facet', literal('Online')
to_field 'format', literal('Research guide')
to_field 'url_fulltext_display' do |record, accumulator|
  urls = record.find_all { |f| f.tag == '856' }
  urls.each do |field|
    value = field['u'].to_s
    accumulator << if value.include? 'prod=NGMA'
                     'http://ezproxy.libweb.linnbenton.edu:2048/login?url=http://infotrac.galegroup.com/itweb/lbcc?db=NGMA'
                   else
                     value.gsub('[LOCATIONID]', 'oregon_sl')
                   end
  end
end
