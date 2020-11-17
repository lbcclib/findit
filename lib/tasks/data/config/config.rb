# frozen_string_literal: true

require 'traject'

settings do
  provide 'solr_writer.max_skipped', -1
  provide 'solr_writer.thread_pool', 2
  provide 'processing_thread_pool', 24
end
