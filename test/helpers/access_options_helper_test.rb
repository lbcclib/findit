require 'test_helper'

class AccessOptionsHelperTest < ActionView::TestCase
  setup :initialize_vars

  test "full text access link is a link" do
    assert is_valid_link display_fulltext_access_link('http://linnbenton.edu')
  end
  test "access options for documents with url_fulltext_display is a link" do
    assert is_valid_link display_access_options(@short_document)
  end
  test "concise access options for documents with url_fulltext_display is a link" do
    assert is_valid_link display_concise_access_options(@short_document)
  end

  test "mode_of_access is correct for eg documents" do
    assert_equal 'library_holdings', mode_of_access(@long_document)
  end
  test "mode_of_access is correct for e-resource documents" do
    assert_equal 'url', mode_of_access(@short_document)
  end

  private
  def initialize_vars
    create_solr_documents
  end
end
