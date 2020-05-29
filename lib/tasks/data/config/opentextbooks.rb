require 'traject'
require_relative 'cover_images.macro'
extend FindIt::Macros::CoverImages


to_field "id", extract_marc("001", :first => true)
to_field "thumbnail_path_ss", cover_image

to_field 'record_provider_facet', literal('Open Textbook Library')
to_field 'record_source_facet', literal('Open Textbook Library')
to_field 'is_electronic_facet', literal('Online')
to_field 'format', literal('Ebook')
to_field 'url_fulltext_display',
                                extract_marc("856|40|u")
to_field 'url_fulltext_display',
                                extract_marc("856|42|u")
