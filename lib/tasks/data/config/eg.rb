# frozen_string_literal: true

require 'traject'
require_relative 'cover_images.macro'
extend FindIt::Macros::CoverImages
require_relative 'lbcc_format.macro'

require_relative 'eg_authority_control.macro'
extend FindIt::Macros::EgAuthorityControl

to_field 'thumbnail_path_ss', cover_image

to_field 'id', extract_marc('001', first: true)

to_field 'record_provider_facet', literal('LBCC Evergreen Catalog')
to_field 'record_source_facet', literal('LBCC Library Catalog')
to_field 'is_electronic_facet' do |record, accumulator|
  field852s = record.find_all { |f| f.tag == '852' }
  field852s.each do |field|
    library = field['b']
    accumulator << case library
                   when 'LBCCHOC'
                     'Healthcare Occupations Center'
                   when 'LBCCBC'
                     'Benton Center'
                   when 'LBCCLIB'
                     'Albany Campus Library'
                   when 'LBCC'
                     'Online'
                   else
                     'Partner Libraries'
                   end
  end
end

to_field 'format', FindIt::Macros::LBCCFormats.lbcc_formats, default('Book')
to_field 'owning_lib_facet', extract_marc('852b')
to_field 'url_fulltext_display', extract_marc('856|40|u')

to_field 'professor_t', extract_marc('971a')
to_field 'course_t', extract_marc('972a')

to_field 'authority_data_t', keywords_from_linked_authority_records
