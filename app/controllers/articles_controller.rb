class ArticlesController < CatalogController
  def show
    begin
      connection = EdsService.get_valid_connection session
      @document = connection.retrieve dbid: params[:db], an: params[:id]
    rescue
    end
  end
end
