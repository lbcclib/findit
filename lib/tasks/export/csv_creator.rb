# frozen_string_literal: true

require 'csv'
require 'library_stdnums'

# Creates CSV files based on data from solr
class CsvCreator
  def initialize(config:, docs: [])
    get_config_from_file config
    if docs.any?
      @docs = docs
    else
      solr = RSolr.connect url: ENV['SOLR_URL']
      response = solr.get 'select', params: { q: config['query'], fl: @fl, facet: false, rows: 2_000_000 }
      @docs = response['response']['docs']
    end
  end

  def write
    CSV.open(filename, 'wb', col_sep: @delimiter, headers: @headers, write_headers: @write_headers) do |csv|
        data.each do |row|
            csv << row
        end
    end
  end

  def data
    data = []
    @docs.each do |doc|
      extract_isbns_from_doc(doc).map do |isbn|
        row = [isbn].concat(extract_non_isbn_field_values(doc),
                            literals_list(:values))
        data << row
      end
    end
    data
  end

  private

  def get_config_from_file(config)
    get_field_configs config
    get_output_settings config
  end

  def get_field_configs(config)
    @isbn_fl = config['fields_containing_isbns']
    @non_isbn_fl =  config['non_isbn_solr_fields']
    @literal_fields = config['literal_fields']
    non_isbn_field_names = @non_isbn_fl&.map { |f| f['field'] }
    @headers = %w[ISBN].concat(non_isbn_field_names, literals_list(:keys)).flatten
    @fl = @isbn_fl + non_isbn_field_names
  end

  def get_output_settings(config)
    @delimiter = config['delimiter'] || ','
    @write_headers = config['include_header_row'] || false
    @prefix = config['output_prefix'] || ''
  end

  def extract_isbns_from_doc(doc)
    isbns = []
    @isbn_fl.each do |field|
      next unless doc[field]

      isbns.concat(doc[field]&.map { |isbn| ::StdNum::ISBN.normalize isbn })
    end
    isbns.uniq
  end

  def filename
    "#{@prefix}#{Time.current.strftime('%Y%m%d%H%M%S')}.csv"
  end

  def extract_non_isbn_field_values(doc)
    return [] unless @non_isbn_fl

    @non_isbn_fl&.map do |field|
      data = doc[field['field']]&.first
      field['character_limit'] ? data[0..field['character_limit']] : data
    end
  end

  def literals_list(method)
    return [] unless @literal_fields

    @literal_fields&.map(&method)&.map(&:first)
  end
end
