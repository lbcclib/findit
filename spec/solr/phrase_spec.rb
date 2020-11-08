# frozen_string_literal: true

RSpec.describe 'solr phrase relevance spec' do
  it 'does appropriate phrase searches for keyword Black Lives Matter' do
    relevant_id = '541433'
    irrelevant_id = '502167'
    resp = solr_resp_doc_ids_only({ 'q' => 'black lives matter' })
    expect(resp).to include(relevant_id).before(irrelevant_id)
  end

  it 'search for keyword Digital Divide' do
    relevant_ids = %w[556265 529813 524094 344167]
    resp = solr_resp_doc_ids_only({ 'q' => 'digital divide' })
    expect(resp).to include(relevant_ids).in_first(6).results
  end

  it 'search for keyword Love and Fear' do
    resp = solr_resp_doc_ids_only({ 'q' => 'Love and Fear' })
    relevant_id = '591432'
    expect(resp).to include(relevant_id).as_first
  end
end
