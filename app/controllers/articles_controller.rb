class ArticlesController < ApplicationController
    
    def show
        #create article object named @document
        #fetch data from API
        #apply values
        @document = Article.new

        if session[:article_api_connection].show_session_token and session[:article_api_connection].show_auth_token
            results = session[:article_api_connection].retrieve(params[:db], params[:id], '', '',
                session[:article_api_connection].show_session_token,
                session[:article_api_connection].show_auth_token)
        end
        if results
            @document.extract_data_from_api_response results['Record']
        end
    end

    protected

end
