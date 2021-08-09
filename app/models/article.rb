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
      author_display: @authors&.shift,
      contributor_display: @authors,
      is_electronic_facet: 'Online',
      issue_t: @issue,
      journal_display: @journal,
      journal_facet: @journal,
      language_facet: @language,
      pages_t: @pages,
      publisher_display: @publisher,
      publisher_t: @publisher,
      pub_date: @pub_date,
      record_provider_facet: 'Open access',
      record_source_facet: 'Open access',
      subject_topic_facet: @subjects,
      title_display: @title,
      title_t: @title,
      url_fulltext_display: @url || openurl_link.to_s,
      volume_t: @volume
    }
  end

  def ==(other_article)
    puts "----------"
    puts "Ours: @doi"
    puts "THeirs: other_article.doi"
    puts "----------"
    @doi == other_article.doi ||
      (@title.casecmp(other_article.title) &&
        (@pub_date == other_article.pubdate ||
        (@volume == other_article.volume && @issue = other_article.issue)))
  end

  def openurl_link
    params = ActionController::Parameters.new(
      'rft.atitle': @title,
      'rft.doi': @doi,
      'rft.date': @pub_date,
      'rft.jtitle': @journal
    ).permit('rft.atitle', 'rft.doi', 'rft.date', 'rft.jtitle')
    .reject { |k, v| v.nil? } # TODO: once this is updated to Rails 6.1.4 or above, change to .compact
    ResourceLink.new "https://linn.on.worldcat.org/atoztitles/link?#{params.to_query}"
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
    @journal = article['container-title']&.first
    @volume = article['volume']
    @doi = article['DOI']
    @language = I18nData.languages[article['language']&.upcase]
    @subjects = article['subject']
  end

  def populate_from_wikidata(triples)
    @id = triples.first[:subject].to_s.gsub('http://www.wikidata.org/entity/', '')
    @title = rdf_get_value_by_property(triples, 'http://www.wikidata.org/prop/direct/P1476') ||
             rdf_get_value_by_property(triples, 'http://www.w3.org/2000/01/rdf-schema#label')
    @authors = rdf_get_values_by_property triples, 'http://www.wikidata.org/prop/direct/P2093'
    @doi = rdf_get_value_by_property triples, 'http://www.wikidata.org/prop/direct/P356'
    @format = rdf_get_value_by_property triples, 'http://www.wikidata.org/prop/direct/P31'
    @issue = rdf_get_value_by_property triples, 'http://www.wikidata.org/prop/direct/P433'
    @journal = rdf_get_value_by_property triples, 'http://www.wikidata.org/prop/direct/P1433'
    @language = rdf_get_value_by_property triples, 'http://www.wikidata.org/prop/direct/P407'
    @pages = rdf_get_value_by_property triples, 'http://www.wikidata.org/prop/direct/P304'
    @pub_date = triples.find { |triple| triple[:predicate] == 'http://www.wikidata.org/prop/direct/P577' }
                       &.value&.to_date&.year
    @subjects = rdf_get_value_by_property triples, 'http://www.wikidata.org/prop/direct/P921'
    @volume = rdf_get_value_by_property triples, 'http://www.wikidata.org/prop/direct/P478'
    puts @title
  end

  def normalize_id(string)
    string ? CGI.escape(string.delete('.')) : nil
  end

  def rdf_get_value_by_property(triples, property_uri)
    match = triples.find {|triple| triple[:predicate] == property_uri }
    return match[:object].to_s if match
  end

  def rdf_get_values_by_property(triples, property_uri)
    triples.select {|triple| triple[:predicate] == property_uri }
           .map{ |triple| triple[:object].to_s }
  end
end