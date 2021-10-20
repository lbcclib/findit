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

  it 'can do another keyword search including an author and title' do
    resp = solr_resp_doc_ids_only({ 'q' => 'radical democracy lummis' })
    relevant_id = '591352'
    expect(resp).to include(relevant_id).as_first
  end

  it 'can do a keyword search including an author and title, ebook' do
    resp = solr_resp_doc_ids_only({ 'q' => 'picture this bang' })
    relevant_id = '593170'
    expect(resp).to include(relevant_id).as_first
  end

  it 'can do a title search' do
    resp = solr_resp_doc_ids_only({ q: 'animal genetics', pf: '${title_pf}', qf: '${title_qf}' })
    relevant_id = 'ocn896839764'
    expect(resp).to include(relevant_id).as_first
  end

  it 'does not weight the author name too heavily' do
    resp = solr_resp_doc_ids_only({ q: 'dolphins' })
    relevant_id = '519341'
    irrelevant_id = 'ocn797917515'
    expect(resp).to include(relevant_id).before(irrelevant_id)
  end

  it 'has a reasonable weight for the genre field' do
    resp = solr_resp_doc_ids_only({ q: 'animal science biographies' })
    relevant_id = 'on1109836794'
    expect(resp).to include(relevant_id).in_first(2).results
  end

end
