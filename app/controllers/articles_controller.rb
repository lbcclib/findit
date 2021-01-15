# frozen_string_literal: true

# Controller for searching article API
class ArticlesController < CatalogController
  include BlacklightRangeLimit::ControllerOverride

  configure_blacklight do |config|
    config.add_facet_field 'eds_publication_type_facet', label: I18n.t('facets.format'), collapse: false, limit: 5
    config.add_facet_field 'pub_year_tisim', label: I18n.t('facets.pub_year'), component: ArticleRangeFacetComponent
    config.add_facet_field 'eds_subject_topic_facet', label: I18n.t('facets.subject'), limit: 5
    config.add_facet_field 'eds_journal_facet', label: I18n.t('facets.journal'), limit: 5
    config.add_facet_field 'eds_language', label: I18n.t('facets.language'), limit: 5
    config.add_facet_field 'eds_subjects_geographic', label: I18n.t('facets.geographic'), limit: 5
    config.add_facet_field 'eds_publisher_facet', label: I18n.t('facets.publisher'), limit: 5
    config.add_facet_field 'eds_content_provider_facet', label: I18n.t('facets.database'), limit: 5
  end

  def index
    if params[:q].blank?
      redirect_to root_url, notice: t('bento.needs_query')
    else
      page = params[:page].present? ? Integer(params[:page]) : 1
      params[:view] = 'detailed'
      results = EdsService.blacklight_style_search params

      if results.records
        records = results.records.map { |record| Article.new record }
        @solr_response = Blacklight::Solr::Response.new(results.to_solr, {})
        @articles = Kaminari.paginate_array(records, total_count: results.stat_total_hits).page(page).per(10)
      end

      # Rearrange to a better order
      @facet_fields = %w[
        eds_publication_type_facet
        pub_year_tisim
        eds_subject_topic_facet
        eds_journal_facet
        eds_language_facet
        eds_subjects_geographic_facet
        eds_publisher_facet
        eds_content_provider_facet
      ]
    end
  end

  def show
    connection = EdsService.connect
    raw_article = connection.retrieve dbid: params[:db], an: CGI.unescape(params[:id])
    @document = Article.new raw_article
  end

  def facet
    @facet = blacklight_config.facet_fields[params[:id]]
    raise ActionController::RoutingError, 'Not Found' unless @facet

    results = EdsService.blacklight_style_search params
    @response = Blacklight::Solr::Response.new(results.to_solr, {})

    @display_facet = @response.aggregations[@facet.field]
    @presenter = (@facet.presenter || Blacklight::FacetFieldPresenter).new(@facet, @display_facet, view_context)
    @pagination = @presenter.paginator
    respond_to do |format|
      format.html do
        # Draw the partial for the "more" facet modal window:
        return render layout: false if request.xhr?
        # Otherwise draw the facet selector for users who have javascript disabled.
      end
      format.json
    end
  end
end
