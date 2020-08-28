# frozen_string_literal: true

require 'traject'
# To have access to various built-in logic
# for pulling things out of MARC21, like `marc_languages`
require 'traject/macros/marc21_semantics'
extend  Traject::Macros::Marc21Semantics
require_relative 'bibtex.macro'
extend FindIt::Macros::Bibtex
require 'traject/macros/marc_format_classifier'
extend Traject::Macros::MarcFormats
require 'traject/macros/marc21'
extend Traject::Macros::Marc21

to_field 'bibtex_t', generate_bibtex

settings do
  provide 'solr.url', 'http://localhost:8983/solr/blacklight-core'
  provide 'solr_writer.max_skipped', -1
  provide 'marc_source.encoding', 'UTF-8'
end

# to_field "id",                  extract_marc("001", :first => true)
to_field 'marc_display',        serialized_marc(format: 'xml')

to_field 'abstract_display',    extract_marc('520a')
to_field 'abstract_t',          extract_marc('520')

to_field 'author_display',      extract_marc('100abcdq:110:111', alternate_script: false, first: true)
to_field 'author_facet',        extract_marc('100abcdq:110abcdgnu:111acdenqu:700abcdq:710abcdgnu:711acdenqu', trim_punctuation: true)
to_field 'author_t',            extract_marc('100abcdq:110abcdgnu:111acdenqu:700abcdq:710abcdgnu:711acdenqu')
to_field 'author_vern_display', extract_marc('100abcdq:110:111', alternate_script: :only)

to_field 'contents_display',    extract_marc('505')
to_field 'contents_t',          extract_marc('505')

to_field 'contributor_display', extract_marc('511a:700abcegqu:710abcdegnu:711acdegjnqu:505r')
to_field 'contributor_t',       extract_marc('511a:700abcegqu:710abcdegnu:711acdegjnqu:505r', trim_punctuation: true)

to_field 'edition_display',     extract_marc('250a')

to_field 'eg_tcn_t',            extract_marc('901c', first: true)

to_field 'followed_by_display', extract_marc('785at')
to_field 'followed_by_t',       extract_marc('785')

to_field 'genre_facet',         extract_marc('655a', trim_punctuation: true) do |_record, accumulator|
  ['Aufsatzsammlung',
   'Electronic book',
   'Electronic books',
   'History',
   'Internet videos'].each do |bad_genre|
     accumulator.delete(bad_genre)
   end
end

to_field 'has_part_display',    extract_marc('774at')
to_field 'has_part_t',          extract_marc('774')

to_field 'is_electronic_facet', extract_marc('950b', first: true) # I can move this out of the python script

to_field 'is_part_of_display',  extract_marc('772at:773at')
to_field 'is_part_of_t',        extract_marc('772:773')

to_field 'isbn_t',              extract_marc('020a:773z:776z:534z:556z')
to_field 'isbn_of_alternate_edition_t',
         extract_marc('020z')

to_field 'language_facet',      marc_languages

to_field 'lc_1letter_facet',    extract_marc('050ab', first: true, translation_map: 'lcc_top_level') do |_rec, acc|
  acc.map! { |x| x[0] }
end
to_field 'lc_callnum_display',  extract_marc('050ab', first: true)
to_field 'lc_b4cutter_facet',   extract_marc('050a', first: true)

to_field 'lccn_t',              extract_marc('010a')

to_field 'note_display',        extract_marc('500a')
to_field 'note_t',              extract_marc('500:508:518:524:534:545:586:585')

to_field 'oclcn_t',             oclcnum

to_field 'place_of_publication_display',
         extract_marc('260a:264a', trim_punctuation: true, first: true, alternate_script: false)
to_field 'place_of_publication_vern_display',
         extract_marc('260a:264a', trim_punctuation: true, first: true, alternate_script: :only)

to_field 'preceeded_by_display',
         extract_marc('785at')
to_field 'preceeded_by_t',      extract_marc('785')

to_field 'pub_date',            marc_publication_date

to_field 'publisher_display',   extract_marc('260b:264b', trim_punctuation: true, alternate_script: false)
to_field 'publisher_vern_display',
         extract_marc('260b:264b', trim_punctuation: true, alternate_script: :only)
to_field 'publisher_t',         extract_marc('260b:264b', trim_punctuation: true)
to_field 'publisher_info_t',    extract_marc('260abef:261abef:262ab:264ab', trim_punctuation: true)

to_field 'publication_note_display',
         extract_marc('362a')

to_field 'record_source_facet',
         extract_marc('950a', first: true)

to_field 'serial_coverage_display',
         extract_marc('362a')

to_field 'series_facet',        marc_series_facet

to_field 'subject_t',           extract_marc('600:610:611:630:650:651avxyz:653aa:654abcvyz:690abcdxyz:691abxyz:692abxyz:693abxyz:656akvxyz:657avxyz:652axyz:658abcd')
to_field 'subject_additional_t',
         extract_marc('600vwxyz:610vwxyz:611vwxyz:630vwxyz:650vwxyz:651vwxyz:654vwxyz:655vwxyz')
to_field 'subject_name_facet', extract_marc('600abcdq:610ab:611ab',
                                            trim_punctuation: true) do |_record, accumulator|
  accumulator.collect! do |value|
    value.gsub(/\A[a-z]/, &:upcase)
  end
end
to_field 'subject_topic_facet', extract_marc('630aa:650aa:654ab',
                                             trim_punctuation: true) do |_record, accumulator|
  # upcase first letter if needed, in MeSH sometimes inconsistently downcased
  ['Electronic book',
   'Electronic books',
   'History',
   'Internet videos',
   'Streaming video'].each do |bad_subject|
    accumulator.delete(bad_subject)
  end
  accumulator.collect! do |value|
    value.gsub(/\A[a-z]/, &:upcase)
  end
end

to_field 'subject_era_facet',   extract_marc('650y:651y:654y:655y', trim_punctuation: true)
to_field 'subject_geo_facet',   extract_marc('651z:650z', trim_punctuation: true)

to_field 'subtitle_display',    extract_marc('245b', trim_punctuation: true, first: true, alternate_script: false)
to_field 'subtitle_vern_display',
         extract_marc('245b', trim_punctuation: true, first: true, alternate_script: :only)
to_field 'subtitle_t',          extract_marc('245b')

to_field 'title_addl_t',        extract_marc('245abnps:130:240abcdefgklmnopqrs:210ab:222ab:242abnp:243abcdefgklmnopqrs:246abcdefgnp:247abcdefgnp')
to_field 'title_added_entry_t', extract_marc('511a:700gklmnoprst:710fgklmnopqrst:711fgklnpst:730abcdefgklmnopqrst:740anp')
to_field 'title_display',       extract_marc('245a', first: true, trim_punctuation: true, alternate_script: false)
to_field 'title_series_t',      extract_marc('440a:490a:800abcdt:400abcd:810abcdt:410abcd:811acdeft:411acdef:830adfgklmnoprst:760ast:762ast')
to_field 'title_t',             extract_marc('245ak', trim_punctuation: true)
to_field 'title_vern_display',  extract_marc('245a', trim_punctuation: true, alternate_script: :only)
to_field 'title_and_statement_of_responsibility_t', extract_marc('245abc')
