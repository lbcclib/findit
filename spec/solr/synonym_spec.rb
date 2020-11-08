# frozen_string_literal: true

RSpec.describe 'solr synonym spec' do
  it 'switches misspelling immingration to immigration' do
    resp = solr_resp_doc_ids_only({ 'q' => 'immingration' })
    relevant_id = '286656'
    expect(resp).to include(relevant_id).in_first(3).results
  end

  it 'knows that college and campus are synonyms' do
    resp = solr_resp_doc_ids_only({ 'q' => 'sexual assault college' })
    relevant_id = '535879'
    expect(resp).to include(relevant_id).as_first
  end

  it 'delivers good results for query: reproductive freedom for women' do
    resp = solr_resp_doc_ids_only({ 'q' => 'reproductive freedom for women' })
    relevant_id = '505189'
    expect(resp).to include(relevant_id).in_first(2).results
  end

  it 'knows that tech and technology are synonyms' do
    resp = solr_resp_doc_ids_only({ q: 'classroom tech' })
    relevant_id = 'ocn828694721'
    expect(resp).to include(relevant_id).as_first
  end
end
