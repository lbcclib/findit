# frozen_string_literal: true

# Controller for searching article API
class ArticlesController < CatalogController
  include BlacklightRangeLimit::ControllerOverride

  configure_blacklight do |config|
    config.add_facet_field 'eds_publication_type_facet', label: I18n.t('facets.format'), collapse: false, limit: 5
    config.add_facet_field 'eds_publication_year_facet', label: I18n.t('facets.pub_year'), limit: 5
    config.add_facet_field 'eds_subject_topic_facet', label: I18n.t('facets.subject'), limit: 5
    config.add_facet_field 'eds_journal_facet', label: I18n.t('facets.journal'), limit: 5
    config.add_facet_field 'eds_language', label: I18n.t('facets.language'), limit: 5
    config.add_facet_field 'eds_subjects_geographic', label: I18n.t('facets.geographic'), limit: 5
    config.add_facet_field 'eds_publisher_facet', label: I18n.t('facets.publisher'), limit: 5
    config.add_facet_field 'eds_content_provider_facet', label: I18n.t('facets.database'), limit: 5
  end

  def index
    if has_search_parameters?
      page = params[:page].present? ? Integer(params[:page]) : 1
      q = params[:q] || 'Linn-Benton Community College'
      search_fields = { 'author' => 'AU:', 'title' => 'TI:', 'all_fields' => '', 'subject' => 'SU:' }
      search_field = params[:search_field] || 'all_fields'
      search_field_code = search_fields[search_field] || ''
      requested_facets = EdsService.eds_facets_from_param params[:f]
      @facets_sent_to_eds = requested_facets

      connection = EdsService.connect
      results = ArticleSearch.send connection, page: page, q: q, search_field: search_field, search_field_code: search_field_code, f: requested_facets
      records = []
      @facets = []

      if results.records
        results.records.each do |record|
          current_article = Article.new record
          records.push current_article
        end
        @articles = Kaminari.paginate_array(records, total_count: results.stat_total_hits).page(page).per(10)

        @solr_response = Blacklight::Solr::Response.new(results.to_solr, {})

        # Rearrange to a better order
        @facet_fields = %w[
          eds_publication_type_facet
          eds_publication_year_facet
          eds_subject_topic_facet
          eds_journal_facet
          eds_language_facet
          eds_subjects_geographic_facet
          eds_publisher_facet
          eds_content_provider_facet
        ]
      end
    else
      redirect_to controller: 'bento', action: 'home'
    end
  end

  def show
    connection = EdsService.connect
    raw_article = connection.retrieve dbid: params[:db], an: CGI.unescape(params[:id])
    @document = Article.new raw_article
  end
end
