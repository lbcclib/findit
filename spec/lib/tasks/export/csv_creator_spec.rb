# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../../lib/tasks/export/csv_creator'

describe 'csv creator' do
  it 'does a thing' do
    config = {
        'fields_containing_isbns' => ['isbn_t'],
        'non_isbn_solr_fields' => [{ 'field' => 'is_electronic_facet', 'label' => 'site' }] }
    docs = [{
        'isbn_t' => ['9768142545', '9789768142542'],
        'is_electronic_facet' => ['Online']
      }]
    csv = CsvCreator.new(config: config, docs: docs)
    expect(csv.data).to eq(['9789768142542', 'Online'])
  end
end
