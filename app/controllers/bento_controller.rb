class BentoController < ApplicationController

  def index
    if params[:q]
      @q = params[:q]
      if params[:showArticles] and !params[:showCatalog]
        redirect_to controller: 'articles', params: request.query_parameters
      elsif params[:showCatalog] and !params[:showArticles]
        redirect_to controller: 'catalog', params: request.query_parameters
      end
    else
      redirect_to action: 'home'
    end
  end

  def home
  end

end
