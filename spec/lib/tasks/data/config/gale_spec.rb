# frozen_string_literal: true

require 'spec_helper'

require 'traject/indexer'
require 'marc'

require 'traject/macros/marc21'
include Traject::Macros::Marc21

describe 'gale config' do
  before do
    @indexer = Traject::Indexer.new
    config = Rails.root.join('lib/tasks/data/config/gale.rb')
    @indexer.load_config_file config
    @record = MARC::Reader.new(file_fixture('gale.mrc').to_s).to_a.first
    @output = @indexer.map_record(@record)
  end

  describe 'url_fulltext_display:' do
    it 'includes the geolocation authentication for Oregon' do
      expect(@output['url_fulltext_display'].first).to include('u=oregon_sl')
    end
  end
end
