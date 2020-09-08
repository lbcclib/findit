# frozen_string_literal: true

RSpec.describe 'solr synonym spec' do
  it 'switches misspelling immingration to immigration' do
    resp = solr_resp_doc_ids_only({ 'q' => 'immingration' })
    expect(resp).to have_documents
  end

  it 'knows that college and campus are synonyms' do
    resp = solr_resp_doc_ids_only({ 'q' => 'sexual assault college' })
    relevant_id = '535879'
    expect(resp).to include(relevant_id).as_first
  end
end
