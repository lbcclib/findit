# frozen_string_literal: true

require 'traject'

to_field 'id', extract_marc('001', first: true)

to_field 'record_provider_facet', literal('LBCC Evergreen Catalog')
to_field 'record_source_facet', literal('LBCC Library Catalog')
to_field 'is_electronic_facet', literal('Online')
to_field 'url_fulltext_display', extract_marc('856|40|u')

to_field 'format', literal('Ebook')

to_field 'professor_t', extract_marc('971a')
to_field 'course_t', extract_marc('972a')
