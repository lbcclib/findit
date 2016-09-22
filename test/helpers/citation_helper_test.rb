require 'test_helper'

class CitationHelperTest < ActionView::TestCase

  setup :initialize_vars

  test "Test that citations are being returned with 1 element in parseable HTML" do
    citations_generated = generate_citations(@short_document)
    citations_generated.each do |val|
      assert Nokogiri::HTML.parse(val[1])
    end
  end

  test "Test that citations are being returned with 4 elements in parseable HTML" do
    citations_generated = generate_citations(@long_document)
    citations_generated.each do |val|
      assert Nokogiri::HTML.parse(val[1])
    end
  end

  test "Test that citations are generated for the correct documents" do
    words_in_citations = []
    citations_generated = generate_citations(@long_document)
    citations_generated.each do |val|
      words = val[1].split
      words.each do |word|
        if word.length > 3
          words_in_citations.push strip_tags(word).downcase.gsub /[[:punct:]]/, ''
        end
      end
    end

    words_in_document = ['print', 'online']
    @words_in_long_document.each do |words|
      words.split.each do |word|
        words_in_document.push word.downcase.gsub /[[:punct:]]/, ''
      end
    end
    words_in_citations.each do |word|
      assert words_in_document.include? word
    end
  end


protected
  def initialize_vars
    @book_title = 'The ' + Faker::Pokemon.name + ' from ' + Faker::Pokemon.location
    @publisher = 'House ' + Faker::GameOfThrones.house + ' Publishing'
    @author = Faker::GameOfThrones.character
    @pub_date = Faker::Number.number(4).to_s

    @short_document = SolrDocument.new
    @short_document['title_display'] = 'How to eat pudding correctly'

    @long_document = SolrDocument.new
    @long_document['title_display'] = @book_title
    @long_document['author_display'] = @author
    @long_document['pub_date'] = Array(@pub_date)
    @long_document['publisher_display'] = Array(@pub_comp)

    @words_in_long_document = [@book_title, @publisher, @author, @pub_date]
  end

end
