# frozen_string_literal: true

class CatalogController < ApplicationController
  include BlacklightRangeLimit::ControllerOverride

  include Blacklight::Catalog

  configure_blacklight do |config|
    config.citeproc = {
      bibtex_field: 'bibtex_t',
      fields: {
        address: 'place_of_publication_display',
        author: 'author_display',
        edition: 'edition_display',
        publisher: 'publisher_display',
        title: 'title_t',
        url: 'url_fulltext_display',
        year: 'pub_date'
      },
      styles: %w[apa chicago-fullnote-bibliography modern-language-association ieee council-of-science-editors],
      format: {
        field: 'format',
        default_format: :book,
        mappings: {
          book: ['Book', 'Musical Score', 'Ebook'],
          misc: ['Map/Globe', 'Non-musical Recording', 'Musical Recording', 'Image', 'Software/Data', 'Video/Film']
        }
      }
    }
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    #
    ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
    config.raw_endpoint.enabled = true

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      fl: '*'
    }

    # solr path which will be added to solr base url before the other solr params.
    # config.solr_path = 'select'
    # config.document_solr_path = 'get'

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    config.index.display_type_field = 'format'
    config.index.thumbnail_field = 'thumbnail_path_ss'
    config.index.partials = %i[index_header obtain journal_contents thumbnail index]
    config.show.partials = %i[show_header show_obtain show_work show_instance]

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for document/show views
    # config.show.title_field = 'title_tsim'
    # config.show.display_type_field = 'format'
    # config.show.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)
    config.add_facet_field 'is_electronic_facet', label: I18n.t('facets.is_electronic'), collapse: false
    config.add_facet_field 'format', label: I18n.t('facets.format'), collapse: false
    config.add_facet_field 'pub_date', label: I18n.t('facets.pub_year'), range: true, collapse: false
    config.add_facet_field 'subject_topic_facet', label: I18n.t('facets.subject'), limit: 20, sort: 'count'
    config.add_facet_field 'language_facet', label: I18n.t('facets.language'), limit: true, sort: 'count'
    config.add_facet_field 'journal_facet', label: I18n.t('facets.journal'), limit: true, sort: 'count'
    config.add_facet_field 'subject_geo_facet', label: I18n.t('facets.geographic'), limit: true, sort: 'count'
    # config.add_facet_field 'subject_era_facet', :label => 'Era of focus', :limit => true, :sort => 'count'
    # config.add_facet_field 'subject_name_facet', :label => 'People and groups', :limit => true, :sort => 'count'
    config.add_facet_field 'genre_facet', label: I18n.t('facets.genre'), limit: true, sort: 'count'
    config.add_facet_field 'series_facet', label: I18n.t('facets.series'), limit: true, sort: 'count'
    config.add_facet_field 'department_facet', label: I18n.t('facets.department'), limit: true, sort: 'count'
    config.add_facet_field 'record_source_facet', label: I18n.t('facets.database'), limit: true
    config.add_facet_field 'author_facet', show: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'title_vern_display', label: I18n.t('blacklight.search.fields.title')
    config.add_index_field 'author_display', label: I18n.t('blacklight.search.fields.author')
    config.add_index_field 'author_vern_display', label: I18n.t('blacklight.search.fields.author')
    config.add_index_field 'format'
    config.add_index_field 'language_facet', label: 'Language'
    config.add_index_field 'pub_date'
    config.add_index_field 'abstract_display', label: 'Abstract'
    config.add_index_field 'journal_display', label: 'Journal'
    config.add_index_field 'article_author_display', label: 'Author'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'title', label: I18n.t('blacklight.search.fields.title'), work: true, itemprop: 'name'
    config.add_show_field 'title_display', label: I18n.t('blacklight.search.fields.title'), work: true
    config.add_show_field 'title_vern_display', label: I18n.t('blacklight.search.fields.title'), work: true, itemprop: 'alternativeHeadline'
    config.add_show_field 'subtitle_display', label: 'Subtitle', work: true, itemprop: 'alternativeHeadline'
    config.add_show_field 'subtitle_vern_display', label: 'Subtitle', work: true, itemprop: 'alternativeHeadline'
    config.add_show_field 'original_title_t', label: 'Original title', work: true, itemprop: 'alternativeHeadline'
    config.add_show_field 'author_display', label: I18n.t('blacklight.search.fields.author'), link_to_facet: :author_facet, link_to_search: :author_facet, itemprop: 'author', work: true
    config.add_show_field 'author_vern_display', label: I18n.t('blacklight.search.fields.author'), itemprop: 'author', work: true
    config.add_show_field 'article_author_display', label: 'Authors', work: true, itemprop: 'contributor', helper_method: 'link_to_article_author_search'
    config.add_show_field 'subject_topic_facet', label: 'Topic terms', limit: 20, work: true, itemprop: 'about', link_to_facet: :subject_topic_facet, link_to_search: :subject_topic_facet
    config.add_show_field 'subject_geo_facet', label: 'Region', work: true, itemprop: 'spatialCoverage', link_to_facet: :subject_geo_facet, link_to_search: :subject_topic_facet
    config.add_show_field 'subject_era_facet', label: 'Era', work: true, itemprop: 'temporalCoverage', link_to_facet: :subject_era_facet, link_to_search: :subject_topic_facet
    config.add_show_field 'subject_name_facet', label: 'People and groups', work: true, itemprop: 'about', link_to_facet: :subject_name_facet, link_to_search: :subject_topic_facet
    config.add_show_field 'abstract_display', label: 'Abstract', work: true, itemprop: 'description'
    config.add_show_field 'preceeded_by_display', label: 'Preceded by', work: true, link_to_facet: :title_facet, link_to_search: :title_facet
    config.add_show_field 'followed_by_display', label: 'Followed by', work: true, link_to_facet: :title_facet, link_to_search: :title_facet
    # config.add_show_field 'article_subject_facet', :label => 'Subject', :work => true, :itemprop => 'about', :helper_method => 'link_to_article_keyword_search'
    config.add_show_field 'article_language_facet', label: 'Language', instance: true, itemprop: 'inLanguage'

    config.add_show_field 'edition_display', label: 'Edition', instance: true, itemprop: 'disambiguatingDescription'
    config.add_show_field 'journal_display', label: 'Journal', instance: true, itemprop: 'source'
    config.add_show_field 'course_t', label: 'Used for course', instance: true, itemprop: 'description'
    config.add_show_field 'professor_t', label: 'Assigned by professor', instance: true, itemprop: 'description'
    config.add_show_field 'contributor_display', label: 'Contributors', link_to_facet: :author_facet, link_to_search: :author_facet, itemprop: 'contributor', instance: true
    config.add_show_field 'format', instance: true, itemprop: 'description'
    config.add_show_field 'publisher_display', label: 'Publisher', instance: true, itemprop: 'publisher'
    config.add_show_field 'publisher_vern_display', label: 'Publisher', instance: true, itemprop: 'publisher'
    config.add_show_field 'pub_date', instance: true, itemprop: 'datePublished'
    config.add_show_field 'language_facet', label: 'Language', link_to_facet: :language_facet, link_to_search: :language_facet, itemprop: 'inLanguage', instance: true
    config.add_show_field 'note_display', label: 'Note', instance: true, itemprop: 'description'
    config.add_show_field 'contents_t', label: I18n.t('blacklight.search.fields.contents'), instance: true, itemprop: 'description'
    config.add_show_field 'isbn_t', label: 'ISBN', itemprop: 'isbn', instance: true
    config.add_show_field 'is_part_of_display', label: 'Is part of', instance: true, link_to_facet: :title_facet, link_to_search: :title_facet, itemprop: 'isPartOf'
    config.add_show_field 'has_part_of_display', label: 'Has part', instance: true, link_to_facet: :title_facet, link_to_search: :title_facet, itemprop: 'hasPart'
    config.add_show_field 'url_suppl_display', label: 'More information', instance: true, helper_method: 'external_link'
    config.add_show_field 'place_of_publication_display', label: 'Published in', itemprop: 'locationCreated', instance: true
    config.add_show_field 'place_of_publication_vern_display', label: 'Published in', itemprop: 'locationCreated', instance: true
    config.add_show_field 'publication_note_display', label: 'Publication details', instance: true, itemprop: 'description'
    config.add_show_field 'record_source_facet', label: 'Collection', instance: true

    config.add_show_field 'eg_tcn_t', label: 'Evergreen Catalog ID', instance: true, itemprop: 'identifier'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', label: I18n.t('blacklight.search.fields.all_fields')

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
        qf: '${title_qf}',
        pf: '${title_pf}'
      }
      field.label = I18n.t('blacklight.search.fields.title')
    end

    config.add_search_field('author') do |field|
      field.solr_parameters = {
        qf: '${author_qf}',
        pf: '${author_pf}'
      }
      field.label = I18n.t('blacklight.search.fields.author')
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.qt = 'search'
      field.solr_parameters = {
        qf: '${subject_qf}',
        pf: '${subject_pf}'
      }
      field.label = I18n.t('blacklight.search.fields.subject')
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # config.add_sort_field "relevance", sort: "score desc", label: 'relevance'
    # config.add_sort_field "year", sort: "pub_date desc", label: 'year'
    # config.add_sort_field "author", sort: "author_sort asc", label: 'author'
    # config.add_sort_field "title", sort: "title_sort asc", label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
    # if the name of the solr.SuggestComponent provided in your solrcongig.xml is not the
    # default 'mySuggester', uncomment and provide it below
    # config.autocomplete_suggester = 'mySuggester'
  end

  def index
    @evergreen_service = EvergreenService.new
    super
  end

  def show
    field_test_converted :bento_metadata
    super
  end

  def journal_contents_note
    params.permit(:journal_name, :locale)
    @journal_name = params[:journal_name]
    exit unless @journal_name

    @locale = params[:locale] || 'en'
    @article_count = search_service.search_results do |search_builder|
      search_builder.where journal_facet: @journal_name
    end.first.total
    exit if @article_count.zero?

    @href = search_action_path(search_state.reset.add_facet_params_and_redirect(:journal_facet, @journal_name))

    render layout: false
  end
end
