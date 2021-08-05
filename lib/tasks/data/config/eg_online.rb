# frozen_string_literal: true

require 'traject'

require_relative 'wikidata_enrichment.macro'
extend FindIt::Macros::WikidataEnrichment

require_relative 'cover_images.macro'
extend FindIt::Macros::CoverImages

require_relative 'lbcc_format.macro'

to_field 'id', extract_marc('001', first: true)

to_field 'thumbnail_path_ss', cover_image

to_field 'record_provider_facet', literal('LBCC Evergreen Catalog')
to_field 'record_source_facet', literal('LBCC Library Catalog')
to_field 'is_electronic_facet', literal('Online')
to_field 'url_fulltext_display', extract_marc('856|40|u')

to_field 'format', FindIt::Macros::LBCCFormats.lbcc_formats, default('Unknown')

to_field 'professor_t', extract_marc('971a')
to_field 'course_t', extract_marc('972a')

to_field 'authority_data_t', keywords_from_wikidata
