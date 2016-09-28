require 'test_helper'

class CitationHelperTest < ActionView::TestCase

  setup :initialize_vars

  test "Test that BibTeX generated on the fly includes @book_title" do
    assert create_bibtex(@long_document).include? @book_title
  end

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
    create_solr_documents   
    @words_in_long_document = [@book_title, @publisher, @author, @pub_date]
  end

end
