# frozen_string_literal: true

require 'dotenv/tasks'
require_relative './export/csv_creator'

namespace :findit do
  namespace :data do
    namespace :export do
      erb = ERB.new(IO.read(Rails.root.join('config/export_styles.yml'))).result(binding)
      styles = YAML.safe_load(erb)
      styles.each do |style, config|
        desc "Export CSV file for #{style}"
        task style => :environment do |_task|
          csv = CsvCreator.new config: config
          csv.write
        end
      end
      desc 'Export a solr backup'
      task as_solr: :environment do
        solr = RSolr.connect url: ENV['SOLR_URL']
        delete_existing_backup solr
        sleep 10 # wait for the delete operation to finish
        create_new_backup solr
      end
    end
  end
end

private

def delete_existing_backup(solr)
  solr.get 'replication', params: {
    command: 'deletebackup',
    name: 'new'
  }
# Don't complain if it's already been deleted
rescue RSolr::Error::Http # rubocop:disable Lint/SuppressedException
end

def create_new_backup(solr)
  solr.get 'replication', params: {
    command: 'backup',
    name: 'new'
  }
end
