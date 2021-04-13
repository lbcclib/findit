# frozen_string_literal: true

RSpec.describe 'solr publisher relevance spec' do
  it 'can include publisher in search fields' do
    resp = solr_resp_doc_ids_only({ 'q' => 'openstax biology' })
    relevant_id = '514920'
    expect(resp).to include(relevant_id).as_first
  end

end
