# frozen_string_literal: true

RSpec.describe 'solr general relevance spec' do
  it 'search for keyword Business in China' do
    relevant_ids = %w[292648 292667]
    resp = solr_resp_doc_ids_only({ 'q' => 'business in china' })
    expect(resp).to include(relevant_ids).in_first(3).results
  end

  it 'can do a keyword search including an author and title' do
    resp = solr_resp_doc_ids_only({ 'q' => 'Criminal Investigation Lasley' })
    relevant_id = '343778'
    expect(resp).to include(relevant_id).as_first
  end

  it 'can do a title search' do
    resp = solr_resp_doc_ids_only({ q: 'animal genetics', pf: '${title_pf}', qf: '${title_qf}' })
    relevant_id = 'ocn896839764'
    expect(resp).to include(relevant_id).as_first
  end
end
