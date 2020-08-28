# frozen_string_literal: true

require 'traject'

to_field 'record_provider_facet', literal('Gale Virtual Reference Library')
to_field 'record_source_facet', literal('Gale Virtual Reference Library')
to_field 'is_electronic_facet', literal('Online')
to_field 'format', literal('Ebook')
to_field 'url_fulltext_display', extract_marc('856u') # GVRL links come with the Proxy Prefix appended
