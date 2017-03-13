require 'coveralls'
Coveralls.wear!

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  class TestSolrDocument < SolrDocument
    attr_writer :_source
  end

  # Add more helper methods to be used by all tests here...
  def create_solr_documents
    @book_title = 'The ' + Faker::Pokemon.name + ' from ' + Faker::Pokemon.location
    @publisher = 'House ' + Faker::GameOfThrones.house + ' Publishing'
    @author = Faker::GameOfThrones.character
    @pub_date = Faker::Number.number(4).to_s

    @short_document = TestSolrDocument.new
    @short_document._source[:title_display] = 'How to eat pudding correctly'
    @short_document._source[:url_fulltext_display] = 'http://duckduckgo.com'


    @long_document = TestSolrDocument.new
    @long_document._source[:eg_tcn_t] = '1234'
    @long_document._source[:title_display] = @book_title
    @long_document._source[:author_display] = @author
    @long_document._source[:pub_date] = Array(@pub_date)
    @long_document._source[:publisher_display] = Array(@pub_comp)
  end
end
