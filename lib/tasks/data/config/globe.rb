# frozen_string_literal: true

require 'traject'

to_field 'id', extract_marc('001', :first => true)
to_field 'record_provider_facet', literal('Drama Online Library')
to_field 'record_source_facet', literal('Globe on Screen')
to_field 'is_electronic_facet', literal('Online')
to_field 'format', literal('Streaming video')
