require 'test_helper'

class CitationHelperTest < ActionView::TestCase
  test "Test that citations are being returned with 1 element in parseable HTML" do

    document = SolrDocument.new
    document['title_display'] = 'How to eat pudding correctly'

    citations_generated = generate_citations(document)
    citations_generated.each do |val|
    # puts val.class
    assert Nokogiri::HTML.parse(val[1])
    end
  end

    test "Test that citations are being returned with 4 elements in parseable HTML" do

      document = SolrDocument.new
      # document['author_display'] = 'David Cluckner'
      # document['title_display'] = 'Chickens are Good People'
      #document['pub_date'] = Array.new('1994')
      # document['publisher_display'] = Array.new('National Chicken Books of Awesome')

      def book_title
        'The ' + Faker::Pokemon.name + ' from ' + Faker::Pokemon.location
      end

      def pub_comp
        'House ' + Faker::GameOfThrones.house + ' Publishing'
      end

      # Faker test
      document['title_display'] = book_title
      document['author_display'] = Faker::GameOfThrones.character
      document['pub_date'] = Array(Faker::Number.number(4).to_s)
      document['publisher_display'] = Array(pub_comp)
      puts  document['title_display'], document['author_display'], document['pub_date'], document['publisher_display']

      citations_generated = generate_citations(document)
      citations_generated.each do |val|
      assert Nokogiri::HTML.parse(val[1])
    end
  end
end
