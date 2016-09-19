require 'test_helper'
include CoverImagesController

class CoverImagesControllerTest < ActionController::TestCase
    test "Trying to extract identifiers from a non-existant solr field returns a blank array" do
        identifiers = extract_identifiers SolrDocument.new, 'dsjfsldjflsdkfjsdlkfjsdlkfjdslkfjsdlfkjsdlkfjsldkfjlskdfs'
        assert_instance_of Array, identifiers
    end
end

