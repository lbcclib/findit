# A model to store cover images
class CoverImage < ActiveRecord::Base
    extend ActiveModel::Callbacks
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    before_validation :check_for_redirection
    validates :solr_id, presence: true
    validates :thumbnail_url, allow_blank: true, url: true

    private

    # Make sure that the image is not a 302
    def check_for_redirection
        begin
            response = Net::HTTP.get_response(self.thumbnail_url)
        rescue
            return :abort
        end
        if '302' == response.code
            self.thumbnail_url = response['location']
        end
    end

end
