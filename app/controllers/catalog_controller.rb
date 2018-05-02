# -*- encoding : utf-8 -*-
#
class CatalogController < ApplicationController  

  require('known_item_search_classifier')

  include BlacklightRangeLimit::ControllerOverride
  include Rails.application.routes.url_helpers

  include Blacklight::Catalog
  include Blacklight::Marc::Catalog

  include CoverImagesController
  helper_method :cover_image_url_for


  rescue_from 'Blacklight::Exceptions::ECONNREFUSED' do |exception|
    flash[:error] = "Find It's data are temporarily unavailable.  We will resolve this issue momentarily."
    redirect_to :action=>'more'
  end

  configure_blacklight do |config|

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      :qt => 'search',
      :qf => %w[
        abstract_t
	authority_data_t^0.5
	author_t^1.5
	contents_t
	followed_by_t
	has_part_t
	is_part_of_t
	isbn_t
	isbn_of_alternate_edition_t
	language_facet
	note_t
	preceeded_by_t
	subject_t
	subject_additional_t
	subject_name_facet
	subject_topic_facet^2.0
	subject_era_facet
	subject_geo_facet
	subtitle_t
	title_t^2.0
        title_and_statement_of_responsibility_t
      ].join(' '),
      :rows => 10,
      :fl => '*',
      :bq => 'is_electronic_facet:"Albany Campus Library"^250.0 "Healthcare Occupations Center"^175.0 Online^30.0 record_source_facet:"eBrary Academic Complete"^25.0 "NCBI Bookshelf"^35.0 "Open Textbook Library"^50.0 pub_date_sort:[2015 TO *]^10.0 [1923 TO *]^30.0',
    }
    
    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select' 
    
    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}' 
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    config.index.display_type_field = 'format'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

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
    config.add_facet_field 'is_electronic_facet', :label => 'Get it', :collapse => false
    config.add_facet_field 'format', :label => 'Format', :collapse => false
    config.add_facet_field 'pub_date_sort', :label => 'Publication year', :range => true, :collapse => false
    config.add_facet_field 'subject_topic_facet', :label => 'Topic', :limit => 20, :sort => 'count'
    config.add_facet_field 'language_facet', :label => 'Language', :limit => true, :sort => 'count'
    config.add_facet_field 'lc_1letter_facet', :label => 'Call number' 
    config.add_facet_field 'subject_geo_facet', :label => 'Region of focus', :limit => true, :sort => 'count'
    config.add_facet_field 'subject_era_facet', :label => 'Era of focus', :limit => true, :sort => 'count'
    config.add_facet_field 'subject_name_facet', :label => 'People and groups', :limit => true, :sort => 'count'
    config.add_facet_field 'genre_facet', :label => 'Genre', :limit => true, :sort => 'count'
    config.add_facet_field 'series_facet', :label => 'Series', :limit => true, :sort => 'count'
    config.add_facet_field 'record_source_facet', :label => 'Source database', :limit => true

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    # config.add_index_field 'title_display', :label => 'Title'

    config.add_index_field 'title_vern_display', :label => 'Title'
    config.add_index_field 'author_display', :label => 'Author'
    config.add_index_field 'author_vern_display', :label => 'Author'
    config.add_index_field 'format', :label => 'Format'
    config.add_index_field 'language_facet', :label => 'Language'
    config.add_index_field 'pub_date', :label => 'Publication year'
    config.add_index_field 'abstract_display', :label => 'Abstract', helper_method: 'snippet'
    config.add_index_field 'journal_display', :label => 'Journal'
    config.add_index_field 'article_author_display', :label => 'Author'


    #config.add_index_field 'lc_callnum_display', :label => 'LC Call #'


    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    config.add_show_field 'title', :label => 'Title', :work => true, :itemprop => 'name'
    config.add_show_field 'title_display', :label => 'Title', :work => true
    config.add_show_field 'title_vern_display', :label => 'Title', :work => true, :itemprop => 'alternativeHeadline'
    config.add_show_field 'subtitle_display', :label => 'Subtitle', :work => true, :itemprop => 'alternativeHeadline'
    config.add_show_field 'subtitle_vern_display', :label => 'Subtitle', :work => true, :itemprop => 'alternativeHeadline'
    config.add_show_field 'original_title_t', :label => 'Original title', :work => true, :itemprop => 'alternativeHeadline'
    config.add_show_field 'author_display', :label => 'Author', :link_to_facet => :author_facet, :link_to_search => :author_facet, :itemprop => 'author', :work => true
    config.add_show_field 'author_vern_display', :label => 'Author', :itemprop => 'author', :work => true
    config.add_show_field 'subject_topic_facet', :label => 'Topic terms', :limit => 20, :work => true, :itemprop => 'about', :link_to_facet => :subject_topic_facet, :link_to_search => :subject_topic_facet
    config.add_show_field 'subject_geo_facet', :label => 'Region' , :work => true, :itemprop => 'spatialCoverage', :link_to_facet => :subject_geo_facet, :link_to_search => :subject_topic_facet
    config.add_show_field 'subject_era_facet', :label => 'Era'  , :work => true, :itemprop => 'temporalCoverage', :link_to_facet => :subject_era_facet, :link_to_search => :subject_topic_facet
    config.add_show_field 'subject_name_facet', :label => 'People and groups', :work => true, :itemprop => 'about', :link_to_facet => :subject_name_facet, :link_to_search => :subject_topic_facet
    config.add_show_field 'abstract_display', :label => 'Abstract', :work => true, :itemprop => 'description'
    config.add_show_field 'preceeded_by_display', :label => 'Preceded by', :work => true, :link_to_facet => :title_facet, :link_to_search => :title_facet
    config.add_show_field 'followed_by_display', :label => 'Followed by', :work => true, :link_to_facet => :title_facet, :link_to_search => :title_facet


    config.add_show_field 'edition_display', :label => 'Edition', :instance => true, :itemprop => 'disambiguatingDescription'
    config.add_show_field 'contributor_display', :label => 'Contributors', :link_to_facet => :author_facet, :link_to_search => :author_facet, :itemprop => 'contributor', :instance => true
    config.add_show_field 'format', :label => 'Format', :instance => true, :itemprop => 'description'
    config.add_show_field 'publisher_display', :label => 'Publisher', :instance => true, :itemprop => 'publisher'
    config.add_show_field 'publisher_vern_display', :label => 'Publisher', :instance => true, :itemprop => 'publisher'
    config.add_show_field 'pub_date', :label => 'Publication date', :instance => true, :itemprop => 'datePublished'
    config.add_show_field 'language_facet', :label => 'Language', :link_to_facet => :language_facet, :link_to_search => :language_facet, :itemprop => 'inLanguage', :instance => true
    config.add_show_field 'note_display', :label => 'Note', :instance => true, :itemprop => 'description'
    config.add_show_field 'contents_display', :label => 'Contents', :instance => true, :itemprop => 'description'
    config.add_show_field 'isbn_t', :label => 'ISBN', :itemprop => 'isbn', :instance => true
    config.add_show_field 'is_part_of_display', :label => 'Is part of', :instance => true, :link_to_facet => :title_facet, :link_to_search => :title_facet, :itemprop => 'isPartOf'
    config.add_show_field 'has_part_of_display', :label => 'Has part', :instance => true, :link_to_facet => :title_facet, :link_to_search => :title_facet, :itemprop => 'hasPart'
    config.add_show_field 'url_suppl_display', :label => 'More information', :instance => true, :helper_method => 'external_link'
    config.add_show_field 'place_of_publication_display', :label => 'Published in', :itemprop => 'locationCreated', :instance => true
    config.add_show_field 'place_of_publication_vern_display', :label => 'Published in', :itemprop => 'locationCreated', :instance => true
    config.add_show_field 'publication_note_display', :label => 'Publication details', :instance => true, :itemprop => 'description'
    config.add_show_field 'record_source_facet', :label => 'Collection', :instance => true


    config.add_show_field 'eg_tcn_t', :label => 'Evergreen Catalog ID', :instance => true, :itemprop => 'identifier'
    #config.add_show_field 'published_display', :label => 'Published'
    #config.add_show_field 'published_vern_display', :label => 'Published'
    #config.add_show_field 'lc_callnum_display', :label => 'Call number'



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
    
    config.add_search_field 'all_fields', :label => 'All Fields'
    

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields. 
    
    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params. 
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = { 
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end
    
    config.add_search_field('author') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = { 
        :qf => '$author_qf',
        :pf => '$author_pf'
      }
    end
    
    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as 
    # config[:default_solr_parameters][:qt], so isn't actually neccesary. 
    config.add_search_field('subject') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.qt = 'search'
      field.solr_local_parameters = { 
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_sort desc, title_sort asc', :label => 'relevance'
    config.add_sort_field 'pub_date_sort desc, title_sort asc', :label => 'year'
    config.add_sort_field 'author_sort asc, title_sort asc', :label => 'author'
    config.add_sort_field 'title_sort asc, pub_date_sort desc', :label => 'title'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5

    # Remove endnote and refworks, since they are not supported by our school
    config.show.document_actions.delete(:refworks)
    config.show.document_actions.delete(:endnote)

    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'

    config.index.thumbnail_method = :display_representative_image

    config.add_results_document_tool :fulltext_link, partial: 'catalog/fulltext_link', if: Proc.new { |context, config, options| options[:document].has? 'url_fulltext_display' }
    config.add_results_document_tool :place_hold_link, partial: 'catalog/place_hold_link', if: Proc.new { |context, config, options| (options[:document].has? 'eg_tcn_t') and (options[:document].has? 'is_electronic_facet')  and ((options[:document]['is_electronic_facet'].include? 'Healthcare Occupations Center') or (options[:document]['is_electronic_facet'].include? 'Albany Campus Library')) }
    config.add_results_document_tool :resource_sharing_link, partial: 'catalog/resource_sharing_link', if: Proc.new { |context, config, options| (options[:document].has? 'eg_tcn_t') and (options[:document].has? 'is_electronic_facet') and (options[:document]['is_electronic_facet'].include? 'Partner Libraries') and !(options[:document]['is_electronic_facet'].include? 'Albany Campus Library' ) and !(options[:document]['is_electronic_facet'].include? 'Healthcare Occupations Center') }
    config.index.partials = [:index_header, :thumbnail, :index, :simple_holdings]
    config.show.partials = [:show_header, :access_options, :show_work, :show_instance]
  end


  #Static about page
  def about
  end

  #Static page offering more search options
  def more
  end

  after_filter :track_search, :only => :index
  after_filter :track_metadata_view, :only => :show

  private

  # Track when users perform a search
  def track_search
    track_action
    SearchFingerprint.create do |sf|
      if params[:q]
        sf.query_string = params[:q]
        unless params[:q].blank?
          c = KnownItemSearchClassifier::Classifier.new
	  begin
            sf.known_item = (:known == (c.is_known_item_search? params[:q]))
          rescue Encoding::InvalidByteSequenceError
          end
        end
      end
      if params[:f]
        sf.facets_used = params[:f].to_json
      end
      if params[:page]
        sf.page = params[:page]
      end
    end
  end

  # Track an action using ahoy for analytics purposes
  def track_action
    ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters.to_json
    ahoy.track_visit
  end

  # Track when users access the show view
  def track_metadata_view
    track_action
    MetadataViewFingerprint.create do |mvf|
      mvf.document_id = @document.id
      mvf.database_code = 'solr'
    end
  end


end
