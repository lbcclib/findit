namespace :findit do
    desc "Install Find It"
    task :install do
        Bundler.with_clean_env do
            sh "bundle install"
        end
        sh 'rails generate blacklight:assets -s'
        sh 'rails generate blacklight:user -s'
        sh 'rails generate devise:install -s'
        sh 'rake db:migrate RAILS_ENV=development'
        sh 'rake db:migrate RAILS_ENV=test'
=begin
        ActiveRecord::Base.establish_connection('test')
        Rake::Task['db:drop'].invoke
        Rake::Task['db:create'].invoke
        Rake::Task['db:migrate'].invoke
        ActiveRecord::Base.establish_connection('development')
        Rake::Task['db:drop'].invoke
        Rake::Task['db:create'].invoke
        Rake::Task['db:migrate'].invoke
        ActiveRecord::Base.establish_connection(ENV['RAILS_ENV'])
=end
    end
end 
