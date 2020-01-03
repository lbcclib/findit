class ArticlesController < CatalogController

  include BlacklightRangeLimit::ControllerOverride

  def index
      connection = EdsService.get_valid_connection session
  end

  def show
    connection = EdsService.get_valid_connection session
    raw_article = connection.retrieve dbid: params[:db], an: params[:id]
    @document = Article.new raw_article
  end
end
