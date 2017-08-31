class ArticleFacetItem < OpenStruct #Blacklight::Solr::Response::Facets::FacetItem
    def label
      super || value
    end
end
