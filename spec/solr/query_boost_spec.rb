# frozen_string_literal: true

RSpec.describe 'solr boost query (bq) spec' do
    it 'boosts English-language results over German language ones' do
      english_id = 'ocn964596760'
      german_id = 'ocn923734430'
      resp = solr_resp_doc_ids_only({ 'q' => 'trauma in adolescents' })
      expect(resp).to include(english_id).before(german_id)
    end
  end
  