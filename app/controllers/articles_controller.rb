# This controller coordinates the connection to the external API and handles all the data it returns
class ArticlesController < ApplicationController
    after_filter :track_metadata_view, :only => :show
    
    # Create article object named @document and fill it with data from the API so that it's all ready to display
    def show
        @document = Article.new

        if session[:article_api_connection].ready?
            results = session[:article_api_connection].retrieve_single_article params[:db], params[:id]
        end
        if results
            @document.extract_data_from_api_response results['Record']
        end
    end

    protected

    def track_metadata_view
        MetadataViewFingerprint.create do |mvf|
          mvf.document_id = @document.id
          mvf.database_code = params[:db]
        end
    end

end
