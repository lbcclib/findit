require 'traject'
require 'traject/array_writer'
require 'traject/indexer'
require 'traject/marc_reader'
require_relative './data/fetch'
include FindIt::Data::Fetch

namespace :findit do
  namespace :data do
    namespace :fetch do
      desc 'Fetch MARC record from JOMI'
      task :jomi do
        file_names = FindIt::Data::Fetch::fetch_http ['https://jomi.com/jomiRecords.mrc'], 'jomi'
      end
    end
    namespace :index do
      desc 'Index MARC record from JOMI'
      task :jomi, [:filename] do |task, args|
        file = File.new(Rails.root + args[:filename])
        settings = Traject::Indexer::Settings.new()
        indexer = Traject::Indexer.new(
            'solr_writer.commit_on_close' => true,
            'solr.url' => Blacklight.connection_config[:url] 
        )
        indexer.load_config_file Rails.root.join('lib', 'tasks', 'data', 'config', 'config.rb')
        reader = Traject::MarcReader.new(file, settings)
        writer = indexer.process_with(reader.to_a, Traject::ArrayWriter.new)
      end
    end
  end

end
