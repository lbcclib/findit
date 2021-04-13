# frozen_string_literal: true

RSpec.describe 'department indexing config' do
  it 'knows welding ebooks are relevant to the welding department' do
    ebook_id = 'ocn302346877'
    resp = RSpecSolr::SolrResponseHash.new(@@solr.get('get', params: { :id => ebook_id, 'fl' => 'department_facet' }))
    expect(resp['doc']['department_facet'].first).to eq('Welding')
  end
end
