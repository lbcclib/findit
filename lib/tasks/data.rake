require_relative './data/fetch'
include FindIt::Data::Fetch

require_relative './data/providers'
include FindIt::Data::Providers

namespace :findit do
  namespace :data do
    namespace :fetch do
      desc 'Fetch MARC record from JOMI'
      task :jomi do
        filenames = FindIt::Data::Fetch::fetch_http ['https://jomi.com/jomiRecords.mrc'], 'jomi'
      end
    end
    namespace :index do
      desc 'Index MARC record from JOMI'
      task :jomi, [:filename] do |task, args|

        marc_file = Rails.root.join(args[:filename]).to_s
        config_dir = Rails.root.join('lib', 'tasks', 'data', 'config').to_s
        args = "-c #{config_dir}/config.rb -c #{config_dir}/jomi.rb -c #{config_dir}/proxy.rb -I #{config_dir} -s solrj_writer.commit_on_close=true"
        system("bundle exec traject #{args} #{marc_file}")
      end
    end
    namespace :fetch_and_index do
      desc 'Fetch and Index MARC records from JOMI'
      task :jomi do
        filenames = FindIt::Data::Fetch::fetch_http ['https://jomi.com/jomiRecords.mrc'], 'jomi'
        filenames.each do |filename|
          Rake::Task['findit:data:index:jomi'].execute({filename: filename})
        end
      end
    end

  end

end
