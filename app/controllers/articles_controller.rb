# frozen_string_literal: true

# Controller for searching article API
class ArticlesController < CatalogController
  include BlacklightRangeLimit::ControllerOverride

  configure_blacklight do |config|
    config.add_facet_field 'eds_publication_type_facet', label: I18n.t('facets.format'), collapse: false, limit: 5
    config.add_facet_field 'pub_year_tisim', label: I18n.t('facets.pub_year'), component: ArticleRangeFacetComponent
    config.add_facet_field 'eds_subject_topic_facet', label: I18n.t('facets.subject'), limit: 5
    config.add_facet_field 'eds_journal_facet', label: I18n.t('facets.journal'), limit: 5
    config.add_facet_field 'eds_language_facet', label: I18n.t('facets.language'), limit: 5
    config.add_facet_field 'eds_subjects_geographic_facet', label: I18n.t('facets.geographic'), limit: 5
    config.add_facet_field 'eds_publisher_facet', label: I18n.t('facets.publisher'), limit: 5
    config.add_facet_field 'eds_content_provider_facet', label: I18n.t('facets.database'), limit: 5
  end

  def index
    redirect_to root_url, notice: t('bento.needs_query') if params[:q].blank?

    params[:view] = 'detailed'
    run_index_search
    return unless @results.records

    process_article_results
  end

  def show
    field_test_converted :bento_metadata
    raw_article = EdsService.retrieve params[:db], CGI.unescape(params[:id])
    @document = Article.new raw_article
  end

  def facet
    @facet = blacklight_config.facet_fields[params[:id]]
    raise ActionController::RoutingError, 'Not Found' unless @facet

    run_index_search
    process_facet_results

    respond_to do |format|
      format.html do
        # Draw the partial for the "more" facet modal window:
        return render layout: false if request.xhr?
        # Otherwise draw the facet selector for users who have javascript disabled.
      end
      format.json
    end
  end

  private

  def run_index_search
    @results = EdsService.blacklight_style_search params
    @solr_response = Blacklight::Solr::Response.new(@results.to_solr, {})
  end

  def process_article_results
    page = params[:page].present? ? Integer(params[:page]) : 1
    records = @results.records.map { |record| Article.new record }
    @articles = Kaminari.paginate_array(records, total_count: @results.stat_total_hits).page(page).per(10)
    set_facet_field_order
  end

  def process_facet_results
    @display_facet = @solr_response.aggregations[@facet.field]
    @presenter = (@facet.presenter || Blacklight::FacetFieldPresenter).new(@facet, @display_facet, view_context)
    @pagination = @presenter.paginator
  end

  def set_facet_field_order
    @facet_fields = %w[
      eds_publication_type_facet
      pub_year_tisim
      eds_subject_topic_facet
      eds_content_provider_facet
      eds_journal_facet
      eds_language_facet
      eds_subjects_geographic_facet
      eds_publisher_facet
    ]
  end
end
