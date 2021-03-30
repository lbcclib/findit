# frozen_string_literal: true

RSpec.describe 'solr format spec' do
  it 'categorizes audiobook format properly' do
    audiobook_id = '594332'
    resp = RSpecSolr::SolrResponseHash.new(@@solr.get('get', params: { :id => audiobook_id, 'fl' => 'format' }))
    expect(resp['doc']['format'].first).to eq('Audiobook')
  end

  it 'defaults to Ebook format for OCLC materials' do
    ebook_with_bad_data = 'on1165547942'
    resp = RSpecSolr::SolrResponseHash.new(@@solr.get('get', params: {
                                                        :id => ebook_with_bad_data, 'fl' => 'format'
                                                      }))
    expect(resp['doc']['format'].first).to eq('Ebook')
  end
end
