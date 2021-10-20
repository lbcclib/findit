# frozen_string_literal: true

require 'dotenv/tasks'

RECORD_PROVIDERS = {
  'eg' => {
    'record_provider_facet' => 'LBCC Evergreen Catalog',
    'fetch_method' => :http,
    'user' => 'lbcc',
    'pass' => ENV['EVERGREEN_PASSWORD'],
    'fetch_url' => lambda {
                     today = DateTime.now
                     sunday = today - today.wday
                     prefix = 'https://libweb.cityofalbany.net/filepile/discovery_layer_exports/lbcc_marc_records_items.'
                     return "#{prefix}#{sunday.strftime('%F')}.mrc"
                   },
    'file_prefix' => 'eg_lbcc',
    'traject_configuration_files' => %w[eg marc],
    'needs_many_processing_threads' => true
  },
  'eg_online' => {
    'record_provider_facet' => 'LBCC Evergreen Catalog',
    'fetch_method' => 'http',
    'user' => 'lbcc',
    'pass' => ENV['EVERGREEN_PASSWORD'],
    'fetch_url' => lambda {
                     today = DateTime.now
                     sunday = today - today.wday
                     prefix = 'https://libweb.cityofalbany.net/filepile/discovery_layer_exports/lbcc_marc_records_uris.'
                     return "#{prefix}#{sunday.strftime('%F')}.mrc"
                   },
    'file_prefix' => 'eg_lbcc',
    'traject_configuration_files' => %w[eg_online marc]
  },
  'jomi' => {
    'record_provider_facet' => 'JoMI Surgical Videos',
    'fetch_method' => :http,
    'fetch_url' => 'https://jomi.com/jomiRecords.mrc',
    'file_prefix' => 'jomi',
    'traject_configuration_files' => %w[marc jomi proxy]
  },
  'oclc' => {
    'record_provider_facet' => 'OCLC',
    'fetch_method' => :ftp,
    'file_prefix' => 'oclc',
    'server' => 'filex-m1.oclc.org',
    'user' => 'fx_olx',
    'pass' => ENV['OCLC_PASSWORD'],
    'directories' => [{
      remote: '/xfer/metacoll/out/ongoing/new',
      local: 'new'
    }, {
      remote: '/xfer/metacoll/out/ongoing/updates',
      local: 'update'
    }],
    'traject_configuration_files' => %w[oclc marc],
    'needs_many_processing_threads' => true
  }
}.freeze
