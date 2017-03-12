require 'coveralls'
Coveralls.wear!

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  class TestSolrDocument < SolrDocument
    attr_writer :title_display, :author_display, :pub_date, :publisher_display, :url_fulltext_display, :eg_tcn_t, :isbn_t
  end

  # Add more helper methods to be used by all tests here...
  def create_solr_documents
    @book_title = 'The ' + Faker::Pokemon.name + ' from ' + Faker::Pokemon.location
    @publisher = 'House ' + Faker::GameOfThrones.house + ' Publishing'
    @author = Faker::GameOfThrones.character
    @pub_date = Faker::Number.number(4).to_s

    @short_document = TestSolrDocument.new
    @short_document.title_display = 'How to eat pudding correctly'

    @long_document = TestSolrDocument.new
    @long_document.title_display = @book_title
    @long_document.author_display = @author
    @long_document.pub_date = Array(@pub_date)
    @long_document.publisher_display = Array(@pub_comp)
  end
end
