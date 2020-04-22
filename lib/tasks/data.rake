require_relative './data/fetch'
include FindIt::Data::Fetch

require_relative './data/providers'
include FindIt::Data::Providers

require 'dotenv/tasks'

namespace :findit do
  namespace :data do

    FindIt::Data::Providers::all.each do |provider, config|
      namespace :fetch do
        desc "Fetch MARC record from #{config['record_provider_facet']}"
        task provider do
          FindIt::Data::Fetch::http config
        end
      end

      namespace :index do
        desc "Index MARC records from #{config['record_provider_facet']}"
        task provider, [:filename] do |task, args|

          marc_file = Rails.root.join(args[:filename]).to_s
          config_dir = Rails.root.join('lib', 'tasks', 'data', 'config').to_s
          config_string = "-c #{config_dir}/config.rb" 
          config['traject_configuration_files'].each do |config_file|
            config_string << " -c  #{config_dir}/#{config_file}.rb "
          end
          args = "#{config_string} -I #{config_dir} -s solr.url=#{Blacklight.connection_config[:url]} -s solrj_writer.commit_on_close=true"
          system("bundle exec traject #{args} #{marc_file}")
        end
      end
      namespace :fetch_and_index do
        desc "Fetch and index MARC records from #{config['record_provider_facet']}"
        task provider do
          filenames = FindIt::Data::Fetch::http config
          filenames.each do |filename|
            Rake::Task["findit:data:index:#{provider}"].execute({filename: filename})
          end
        end
      end
    end

  end

end
