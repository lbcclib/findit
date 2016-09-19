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
    test "Can cache a cover image with a proper solr_id and thumbnail_url" do
        cover = CoverImage.new solr_id: 12345, thumbnail_url: 'https://ia800808.us.archive.org/zipview.php?zip=/28/items/olcovers68/olcovers68-S.zip&file=686643-S.jpg'
        assert cover.valid?
    end
end
