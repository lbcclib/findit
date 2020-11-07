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
      namespace :fetch do
        desc "Fetch MARC record from #{config['record_provider_facet']}"
        task provider => :environment do
          method = FindIt::Data::Fetch.method(config['fetch_method'])
          method.call(config)
        end
      end

      namespace :index do
        desc "Index MARC records from #{config['record_provider_facet']}"
        task provider, [:filename] => :environment do |_task, args|
          config_dir = Rails.root.join('lib/tasks/data/config').to_s
          config_string = "-c #{config_dir}/config.rb"
          config['traject_configuration_files'].each do |config_file|
            config_string += " -c  #{config_dir}/#{config_file}.rb "
          end
          marc_file = Rails.root.join(args[:filename]).to_s
          args = "#{config_string} -I #{config_dir} -s solr.url=#{Blacklight.connection_config[:url]}"
          system("bundle exec traject #{args} #{marc_file}")
        end
      end
      namespace :fetch_and_index do
        desc "Fetch and index MARC records from #{config['record_provider_facet']}"
        task provider => :environment do
          method = FindIt::Data::Fetch.method(config['fetch_method'])
          filenames = method.call(config)
          filenames.each do |filename|
            Rake::Task["findit:data:index:#{provider}"].execute({ filename: filename })
          end
        end
      end
      namespace :delete do
        desc "Delete all solr records from #{config['record_provider_facet']}"
        task provider => :environment do
          FindIt::Data::Delete.by_record_provider_facet config['record_provider_facet']
        end
      end
    end
    namespace :index do
      desc 'Index sample data (perhaps for running tests)'
      task sample: :environment do
        fixture_providers = %w[eg gale oclc]
        fixture_providers.each do |fixture_provider|
          Rake::Task["findit:data:index:#{fixture_provider}"].execute({
                                                                        filename: "spec/fixtures/files/#{fixture_provider}.mrc"
                                                                      })
          Rake::Task['findit:data:commit'].execute
        end
      end
    end
    task commit: :environment do
      system("bundle exec traject -x commit -s solr.url=#{Blacklight.connection_config[:url]} "\
             '-s solr_writer.http_timeout=1200 '\
             "-c #{Rails.root.join('lib/tasks/data/config/config.rb')}")
    end
  end
end
