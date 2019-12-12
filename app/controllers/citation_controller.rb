class CitationController < ApplicationController
  include Blacklight::Searchable
  def print
    _, document = search_service.fetch(params[:id])
    bibtex = BibTeX.parse(document.first 'bibtex_t')

    processor = CiteProc::Processor.new format: 'html', style: 'apa'
    processor.import bibtex.to_citeproc
    puts processor.inspect
    @citation = processor.render(:bibliography, id: 'resource').first.tr('{}', '')
    render layout: false
  end
end
