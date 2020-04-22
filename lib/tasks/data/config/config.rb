require 'traject'

settings do
  if c = Blacklight.connection_config
      provide "solr.url", c[:url]
  end
  provide "solr_writer.max_skipped", -1
end

