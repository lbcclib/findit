# frozen_string_literal: true

require 'traject'

settings do
  provide 'solr_writer.max_skipped', -1
  provide 'nokogiri.namespaces', {
    'oai' => 'http://www.openarchives.org/OAI/2.0/',
    'dc' => 'http://purl.org/dc/elements/1.1/',
    'oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/'
  }
  provide 'nokogiri.each_record_xpath', '//oai:record'
end

to_field 'id', extract_xpath('/oai:record/oai:header/oai:identifier', to_text: false) do |_record, accumulator|
  accumulator.map! do |xml_node|
    Digest::MD5.hexdigest(xml_node)
  end
end

to_field 'abstract_display', extract_xpath('/oai:record/oai:metadata/oai_dc:dc/dc:description')
to_field 'abstract_t', extract_xpath('/oai:record/oai:metadata/oai_dc:dc/dc:description')

to_field 'author_display', extract_xpath('/oai:record/oai:metadata/oai_dc:dc/dc:creator[1]')
to_field 'author_t', extract_xpath('/oai:record/oai:metadata/oai_dc:dc/dc:creator')

to_field 'contributor_display', extract_xpath('/oai:record/oai:metadata/oai_dc:dc/dc:contributor')
to_field 'contributor_t', extract_xpath('/oai:record/oai:metadata/oai_dc:dc/dc:contributor')

to_field 'is_electronic_facet', literal('Online')

to_field 'subject_topic_ssim', extract_xpath('/oai:record/oai:metadata/oai_dc:dc/dc:subject')

to_field 'title_display', extract_xpath('/oai:record/oai:metadata/oai_dc:dc/dc:title[1]')
to_field 'title_t', extract_xpath('/oai:record/oai:metadata/oai_dc:dc/dc:title')
