# frozen_string_literal: true

require 'traject'
require_relative 'cover_images.macro'
extend FindIt::Macros::CoverImages
require_relative 'lbcc_format.macro'
extend Traject::Macros::LbccFormats

to_field 'thumbnail_path_ss', cover_image

to_field 'id', extract_marc('001', first: true)

to_field 'record_provider_facet', literal('LBCC Evergreen Catalog')
to_field 'record_source_facet', literal('LBCC Library Catalog')
to_field 'is_electronic_facet' do |record, accumulator|
  field852s = record.find_all { |f| f.tag == '852' }
  field852s.each do |field|
    library = field['b']
    accumulator << if library == 'LBCCHOC'
                     'Healthcare Occupations Center'
                   elsif library == 'LBCCBC'
                     'Benton Center'
                   elsif library == 'LBCCLIB'
                     'Albany Campus Library'
                   elsif library == 'LBCC'
                     'Online'
                   else
                     'Partner Libraries'
                   end
  end
end

to_field 'format', lbcc_formats
to_field 'owning_lib_facet', extract_marc('852b')
to_field 'url_fulltext_display', extract_marc('856|40|u')

to_field 'professor_t', extract_marc('971a')
to_field 'course_t', extract_marc('972a')

require 'open-uri'
require 'traject'

to_field 'authority_data_t' do |record, accumulator|
  authorizable_fields = record.find_all { |f| %w[100 110 111 600 610 611 630 650 651 700 710 711 730 800 810 811 830].include? f.tag }
  authorizable_fields.each do |field|
    authorized_subfields = field.find_all { |subfield| subfield.code == '0' }
    authorized_subfields.each do |subfield|
      control_no = subfield.value.delete('^0-9')
      eg_authority_url = "http://libcat.linnbenton.edu/opac/extras/supercat/retrieve/marcxml/authority/#{control_no}"
      begin
        open(eg_authority_url) do |ar|
          reader = MARC::XMLReader.new(ar)
          reader.each do |arecord|
            interesting_authority_fields = arecord.find_all { |f| %w[400 410 411 430 447 448 450 451 455 500 510 511 530 550 551 555 663 664 665 666 680 681 682 700 710 711 730 747 748 750 751 755 780 781 782].include? f.tag }
            interesting_authority_fields.each do |afield|
              afield.each do |asubfield|
                accumulator << asubfield.value unless asubfield.code == '0'
              end
            end
          end
        end
      rescue StandardError
      end
    end
  end
end
