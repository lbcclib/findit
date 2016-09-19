require 'test_helper'
include CoverImagesController

class CoverImagesControllerTest < ActionController::TestCase
    test "Trying to extract identifiers from a non-existant solr field returns a blank array" do
        identifiers = extract_identifiers SolrDocument.new, 'dsjfsldjflsdkfjsdlkfjsdlkfjdslkfjsdlfkjsdlkfjsldkfjlskdfs'
        assert_instance_of Array, identifiers
    end
    test "Trying to extract identifiers from a singleton solr field returns an array" do
        document = SolrDocument.new
        document['isbn_t'] = '9781595581037'
        identifiers = extract_identifiers document, 'isbn_t'
        assert_instance_of Array, identifiers
        assert_equal 1, identifiers.size
    end
end

