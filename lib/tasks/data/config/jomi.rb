require 'traject'

to_field 'record_provider_facet', literal('JoMI Surgical Videos')
to_field 'record_source_facet', literal('JoMI Surgical Videos')
to_field 'is_electronic_facet', literal('Online')
to_field 'format', literal('Streaming video')
to_field 'id' do |record, accumulator|
	field001s = record.find_all {|f| f.tag == '001'}
	field001s.each do |field|
		id = 'jomi' + field.value
		accumulator = [id]
	end
end
