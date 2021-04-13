# frozen_string_literal: true

require 'traject'
require_relative 'cover_images.macro'
extend FindIt::Macros::CoverImages
require_relative 'oclc_format.macro'

to_field 'thumbnail_path_ss', cover_image

to_field 'id', extract_marc('001', first: true)

to_field 'record_provider_facet', literal('OCLC')
to_field 'record_source_facet', extract_marc('950a')
to_field 'is_electronic_facet', literal('Online')

to_field 'format', FindIt::Macros::OCLCFormat.assign_format, default('Ebook')

to_field 'url_fulltext_display', extract_marc('856|40|u')
