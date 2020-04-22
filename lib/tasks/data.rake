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

        marc_file = Rails.root.join(args[:filename]).to_s
        config_dir = Rails.root.join('lib', 'tasks', 'data', 'config').to_s
        args = "-c #{config_dir}/config.rb -c #{config_dir}/jomi.rb -c #{config_dir}/proxy.rb -I #{config_dir} -s solrj_writer.commit_on_close=true"
        system("bundle exec traject #{args} #{marc_file}")
      end
    end
  end

end
