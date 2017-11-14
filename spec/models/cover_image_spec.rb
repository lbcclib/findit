require 'rails_helper'

RSpec.describe CoverImage, type: :model do
    it "Can't cache a cover image without a solr id" do
        stub_request(:get, "https://covers.openlibrary.org/b/oclc/428817148-M.jpg")
         cover = CoverImage.new(thumbnail_url: 'https://covers.openlibrary.org/b/oclc/428817148-M.jpg')
         expect(cover).to_not be_valid
    end
    it "Can't cache a cover image with an invalid URL" do
        cover = CoverImage.new(solr_id: 12345, thumbnail_url: 'abcdefg')
        expect(cover).to_not be_valid
    end
    it "Can't cache a cover image with a URL that returns a 404" do
        stub_request(:get, "http://httpstat.us/404").to_return(status: 404)
        cover = CoverImage.new(solr_id: 12345, thumbnail_url: 'http://httpstat.us/404')
        expect(cover).to_not be_valid
    end
    it "Can't cache a cover image with a URL that returns a 500" do
        stub_request(:get, "http://httpstat.us/500").to_return(status: 500)
        cover = CoverImage.new(solr_id: 12345, thumbnail_url: 'http://httpstat.us/500')
        expect(cover).to_not be_valid
    end
    it "Can't cache a cover image with a URL that returns a 200 not found message" do
        stub_request(:get, "https://covers.openlibrary.org/b/isbn/0071381333-S.jpg?default=false").to_return(status: 200, body: 'not found')
        cover = CoverImage.new(solr_id: 12345, thumbnail_url: 'https://covers.openlibrary.org/b/isbn/0071381333-S.jpg?default=false')
        expect(cover).to_not be_valid
    end
    it "Redirects if url returns a 302" do
        #allow(Net::HTTP).to receive(:get_response).and_return('')
        stub_request(:get_response, 'http://heartland.com').to_return(status: 302, headers:{'Location' => 'http://newfoundland.com'})
        cover = CoverImage.new(thumbnail_url: 'http://heartland.com')
        #cover.check_for_redirection()
        expect(cover.thumbnail_url).to eq('http://newfoundland.com')
    end
end
