# frozen_string_literal: true

USER_AGENT = 'LBCC library (libref@linnbenton.edu) Ruby 2.6'

require 'csv'
require 'sparql/client'

namespace :findit do
  namespace :data do
    namespace :index do
      task sample_articles: :environment do
        index_holdings_from_kbart filename: Rails.root.join('spec/fixtures/files/kbart.txt')
        Rake::Task['findit:data:commit'].execute
      end
    end
  end
end

def index_holdings_from_kbart(filename:)
  puts "indexing #{filename}"
  periodicals = CSV.read(filename, 'r', col_sep: "\t",
                         headers: true, quote_char: "\x00",
                         encoding: 'utf-8')
                   .map { |row| Periodical.new row}
                   .select(&:valid?)
  write_to_solr periodicals
  write_to_solr periodicals.map(&:articles).flatten
end



def write_to_solr(contents)
  solr = RSolr.connect url: ENV['SOLR_URL']
  solr.add(contents.map(&:to_solr))
end


