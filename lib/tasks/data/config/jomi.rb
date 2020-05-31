# frozen_string_literal: true

require 'traject'

to_field 'record_provider_facet', literal('JoMI Surgical Videos')
to_field 'record_source_facet', literal('JoMI Surgical Videos')
to_field 'is_electronic_facet', literal('Online')
to_field 'format', literal('Streaming video')
to_field 'id' do |record, accumulator|
  id = "jomi#{record['001'].value}"
  accumulator << id
end
