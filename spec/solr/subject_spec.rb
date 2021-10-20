# frozen_string_literal: true

RSpec.describe 'subject search spec' do
  it 'can do subject search' do
    resp = solr_resp_doc_ids_only({ 'q' => 'animal', 'qf' => '${subject_qf}' })
    relevant_id = 'on1109836794'
    expect(resp).to include(relevant_id)
  end
end
