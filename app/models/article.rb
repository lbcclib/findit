class Article
  def initialize(crossref: nil, wikidata: nil)
    if crossref
      populate_from_crossref crossref
    elsif wikidata
      populate_from_wikidata wikidata
    end
  end

  def to_solr
    {
      id: @id,
      format: @format,
      abstract_display: @abstract,
      is_electronic_facet: 'Online',
      publisher_display: @publisher,
      publisher_t: @publisher,
      pub_date: @pub_date,
      record_provider_facet: 'Open access',
      record_source_facet: 'Open access',
      title_display: @title,
      title_t: @title,
      url_fulltext_display: @url
    }
  end

  private
  def populate_from_crossref(article)
    @id = normalize_id(article['DOI']) || article['title'].first.gsub(/\s+/, '')
    @format = article['type'] || 'Article'
    @abstract = ActionController::Base.helpers.strip_tags(article['abstract'])
    @publisher = article['publisher']
    @pub_date = article['created']['date-parts'].first[0]
    @title = article['title'].first
    @url = article['link'].first['URL']
  end


  def normalize_id(string)
    string ? CGI.escape(string.gsub('.', '')) : nil
  end
end