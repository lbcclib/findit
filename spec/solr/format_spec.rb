# frozen_string_literal: true

RSpec.describe 'solr format spec' do
  it 'categorizes audiobook format properly' do
    audiobook_id = '594332'
    resp = RSpecSolr::SolrResponseHash.new(@@solr.get('get', params: { :id => audiobook_id, 'fl' => 'format' }))
    expect(resp['doc']['format'].first).to eq('Audiobook')
  end
end
