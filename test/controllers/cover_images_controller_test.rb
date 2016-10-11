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
    test "recent_enough? returns true for recent date" do
        assert recent_enough?(1.day.ago.to_s(:db))
    end
    test "recent_enough? returns false for really old date" do
        assert_not recent_enough?(12.years.ago.to_s(:db))
    end
    test "get_image_url returns a valid URI" do
        assert_instance_of URI::HTTP, get_image_url('1234567890', 'ISBN', 'M')
    end
end

