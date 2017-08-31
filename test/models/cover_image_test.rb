require 'test_helper'

class CoverImageTest < ActiveSupport::TestCase
    test "Can't cache a cover image without a solr id" do
        cover = CoverImage.new thumbnail_url: 'https://covers.openlibrary.org/b/oclc/428817148-M.jpg'
        assert_not cover.valid?
    end
    test "Can't cache a cover image with an invalid URL" do
        cover = CoverImage.new solr_id: 12345, thumbnail_url: 'abcdefg'
        assert_not cover.valid?
    end
    test "Can't cache a cover image with a URL that returns a 404" do
        cover = CoverImage.new solr_id: 12345, thumbnail_url: 'http://httpstat.us/404'
        assert_not cover.valid?
    end
    test "Can't cache a cover image with a URL that returns a 500" do
        cover = CoverImage.new solr_id: 12345, thumbnail_url: 'http://httpstat.us/500'
        assert_not cover.valid?
    end
    test "Can't cache a cover image with a URL that returns a 200 not found message" do
        cover = CoverImage.new solr_id: 12345, thumbnail_url: 'https://covers.openlibrary.org/b/isbn/0071381333-S.jpg?default=false'
        assert_not cover.valid?
    end
end
