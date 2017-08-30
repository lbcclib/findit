# This controller coordinates the connection to the external API and handles all the data it returns
class ArticlesController < CatalogController
    after_filter :track_metadata_view, :only => :show

    configure_blacklight do |config|
      config.add_show_field 'article_author_display', :label => 'Authors', :work => true, :itemprop => 'contributor', :helper_method => 'link_to_article_search'
      config.add_show_field 'journal_display', :label => 'Journal', :instance => true, :itemprop => 'isPartOf', :helper_method => 'link_to_article_search'
      config.add_show_field 'article_subject_facet', :label => 'Subject', :work => true, :itemprop => 'about', :helper_method => 'link_to_article_search'
      config.add_show_field 'article_language_facet', :label => 'Language', :instance => true, :itemprop => 'inLanguage'
      config.add_show_field 'pubtype', :label => 'Publication type', :instance => true, :itemprop => 'description'
    end
    
    # Create article object named @document and fill it with data from the API so that it's all ready to display
    def show
        @document = Article.new

        if session[:article_api_connection].ready?
            results = session[:article_api_connection].retrieve_single_article params[:db], params[:id]
        end
        if results
            @document.extract_data_from results
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
