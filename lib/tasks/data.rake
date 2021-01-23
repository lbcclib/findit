# frozen_string_literal: true

require 'dotenv/tasks'
require 'marc'

namespace :findit do
  namespace :data do
    require_relative './data/fetch'
    include FindIt::Data::Fetch

    require_relative './data/providers'
    include FindIt::Data::Providers

    require_relative './data/delete'
    include FindIt::Data::Delete

    FindIt::Data::Providers.all.each do |provider, config|
      namespace :index do
        desc "Index MARC records from #{config['record_provider_facet']}"
        task provider, [:filename] => :environment do |_task, args|
          config_dir = Rails.root.join('lib/tasks/data/config')
          config_file_list = config['traject_configuration_files']
                             .map { |config_file| "-c #{config_dir}/#{config_file}.rb" }
                             .join ' '
          command = 'bundle exec traject'\
                    " -c #{config_dir}/config.rb"\
                    " #{config_file_list}"\
                    " -s processing_thread_pool=#{num_threads(Rails.env, config['needs_many_processing_threads'])}"\
                    " -I #{config_dir}"\
                    " -s solr.url=#{Blacklight.connection_config[:url]}"\
                    " #{Rails.root.join(args[:filename])}"
          system command
        end
      end
      namespace :delete do
        desc "Delete all solr records from #{config['record_provider_facet']}"
        task provider => :environment do
          FindIt::Data::Delete.by_record_provider_facet config['record_provider_facet']
        end
      end
    end

    FindIt::Data::Providers.all.select { |_provider, config| config['fetch_method'] }
                           .each do |provider, config|
      namespace :fetch do
        desc "Fetch MARC record from #{config['record_provider_facet']}"
        task provider => :environment do
          method = FindIt::Data::Fetch.method(config['fetch_method'])
          method.call(config)
        end
      end
      namespace :fetch_and_index do
        desc "Fetch and index MARC records from #{config['record_provider_facet']}"
        task provider => :environment do
          method = FindIt::Data::Fetch.method(config['fetch_method'])
          filenames = method.call(config)
          filenames.map do |filename|
            Thread.new do
              Rake::Task["findit:data:index:#{provider}"].execute({ filename: filename })
            end
          end.each(&:join)
        end
      end
    end

    namespace :fetch_and_index do
      desc 'Fetch and index from all sources that can be fetched automatically'
      task all: :environment do
        FindIt::Data::Providers.all
                               .select { |_provider, config| config['fetch_method'] }
                               .sort_by { |_provider, config| config['needs_many_processing_threads'] ? 0 : 1 }
                               .map do |provider, _config|
          Thread.new do
            Rake::Task["findit:data:fetch_and_index:#{provider}"].execute
          end
        end.each(&:join)
        Rake::Task['findit:data:commit'].execute
      end
    end

    namespace :index do
      desc 'Index sample data (perhaps for running tests)'
      task sample: :environment do
        fixture_providers = %w[eg eg_online gale oclc]
        fixture_providers.each do |fixture_provider|
          Rake::Task["findit:data:index:#{fixture_provider}"].execute({
                                                                        filename: "spec/fixtures/files/#{fixture_provider}.mrc"
                                                                      })
        end
        Rake::Task['findit:data:commit'].execute
      end
    end
    task commit: :environment do
      system("bundle exec traject -x commit -s solr.url=#{Blacklight.connection_config[:url]} "\
             '-s solr_writer.http_timeout=1200 '\
             "-c #{Rails.root.join('lib/tasks/data/config/config.rb')}")
    end
  end
end

def num_threads(environment, needs_many_processing_threads)
  return 35 if environment == 'indexer' && needs_many_processing_threads

  3
end
