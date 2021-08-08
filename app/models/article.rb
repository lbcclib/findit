class Article
  attr_accessor :doi, :issue, :pub_date, :title, :volume

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
      issue_t: @issue,
      language_facet: @language,
      publisher_display: @publisher,
      publisher_t: @publisher,
      pub_date: @pub_date,
      record_provider_facet: 'Open access',
      record_source_facet: 'Open access',
      title_display: @title,
      title_t: @title,
      topic_subject_facet: @subjects,
      url_fulltext_display: @url,
      volume_t: @volume
    }
  end

  def ==(other_article)
    @doi == other_article.doi ||
      (@title.casecmp(other_article.title) &&
        (@pub_date == other_article.pubdate ||
        (@volume == other_article.volume && @issue = other_article.issue)))
  end

  private
  def populate_from_crossref(article)
    @id = normalize_id(article['DOI']) || article['title'].first.gsub(/\s+/, '')
    @format = article['type'] || 'Article'
    @abstract = ActionController::Base.helpers.strip_tags(article['abstract'])
    @publisher = article['publisher']
    @pub_date = article['created']['date-parts'].first[0]
    @title = ActionController::Base.helpers.strip_tags(article['title'].first)
    @url = article['link'].first['URL']
    @issue = article['issue']
    @volume = article['volume']
    @doi = article['DOI']
    @language = I18nData.languages[article['language']&.upcase]
    @subjects = article['subject']
  end

  def populate_from_wikidata(triples)
    @id = triples.first[:subject].to_s.gsub('http://www.wikidata.org/entity/', '')
    @title = rdf_get_value_by_property triples, 'http://www.wikidata.org/prop/direct/P1476'
  end

  def normalize_id(string)
    string ? CGI.escape(string.gsub('.', '')) : nil
  end

  def rdf_get_value_by_property(triples, property_uri)
    match = triples.find {|triple| triple[:predicate] == property_uri }
    return match[:object].to_s if match
  end
end