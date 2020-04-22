module FindIt
    module Data
        module Providers
            def record_providers
                return {
                    'opentextbooks' => {
                        'fetch_url' => 'https://open.umn.edu/opentextbooks/MARC/OTL20180209.mrc',
                         # Manually change this URL per http://open.umn.edu/opentextbooks/Discovery.aspx
                        'record_provider_facet' => 'Open Textbook Library',
                        'traject_configuration_files' => ['opentextbooks.rb'],
                        'file_prefix' => 'umn_otl',
                        'fetch_method' => 'http',
                        },
                    'galedbs' => {
                        'record_provider_facet' => 'Gale Databases',
                        'fetch_method' => 'http',
                        'fetch_url' => ['http://access.gale.com/api/dropoff/resources/ovic.mrc',
                            'http://access.gale.com/api/dropoff/resources/uhic.mrc',
                            'http://access.gale.com/api/dropoff/resources/ngma.mrc'],
                        'file_prefix' => 'gale_dbs',
                        'traject_configuration_files' => ['galedbs.rb'],
                        },
                    'globe' => {
                        #This one is fetched manually from http://www.dramaonlinelibrary.com/pages/marc-records,
        	            #because it's a zip file.  Go to Video Collections > Globe on Screen
                        'record_provider_facet' => 'Drama Online Library',
                        'traject_configuration_files' => ['globe.rb', 'proxy.rb',], 
                     },
                    'gvrl' => {
                        #This one is fetched manually from support.gale.com
                        'record_provider_facet' => 'Gale Virtual Reference Library',
                        'traject_configuration_files' => ['gvrl.rb',], 
                        },
                    'eg' => {
                        'record_provider_facet' => 'LBCC Evergreen Catalog',
                        'fetch_method' => 'http',
                        'fetch_opts' => {'user' => 'lbcc',
                            'pass' => ENV['EVERGREEN_PASSWORD']},
                        'fetch_url' => lambda {
                                today = DateTime.now
                                sunday = today - today.wday
                                prefix = 'https://libweb.cityofalbany.net/filepile/discovery_layer_exports/lbcc_marc_records_items.'
                                return prefix + sunday.strftime('%F') + '.mrc'
                            },
                        'file_prefix' => 'eg_lbcc',
                        'traject_configuration_files' => ['eg_lbcc.rb',],
                        },
                    'eg_online' => {
                        'record_provider_facet' => 'LBCC Evergreen Catalog',
                        'fetch_method' => 'http',
                        'fetch_opts' => {'user' => 'lbcc',
                            'pass' => ENV['EVERGREEN_PASSWORD']},
                        'fetch_url' => lambda {
                                today = DateTime.now
                                sunday = today - today.wday
                                prefix = 'https://libweb.cityofalbany.net/filepile/discovery_layer_exports/lbcc_marc_records_uris.'
                                return prefix + sunday.strftime('%F') + '.mrc'
                            },
                        'file_prefix' => 'eg_lbcc',
                        'traject_configuration_files' => ['eg_lbcc_online.rb', 'link.rb', 'eg_authorities.rb'],
                        },
                    'eg_online_with_authority_control' => {
                        'record_provider_facet' => 'LBCC Evergreen Catalog',
                        'fetch_method' => 'http',
                        'fetch_opts' => {'user' => 'lbcc',
                            'pass' => ENV['EVERGREEN_PASSWORD']},
                        'fetch_url' => lambda {
                                today = DateTime.now
                                sunday = today - today.wday
                                prefix = 'http://libweb.cityofalbany.net/filepile/discovery_layer_exports/lbcc_marc_records_uris.'
                                return prefix + sunday.strftime('%F') + '.mrc'
                            },
                        'file_prefix' => 'eg_lbcc',
                        'traject_configuration_files' => ['eg_authorities.rb', 'eg_lbcc_online.rb', 'link.rb', 'eg_authorities.rb'],
                        },
                    'eg_with_authority_control' => {
                        'record_provider_facet' => 'LBCC Evergreen Catalog',
                        'fetch_method' => 'http',
                        'fetch_opts' => {'user' => 'lbcc',
                            'pass' => ENV['EVERGREEN_PASSWORD']},
                        'fetch_url' => lambda {
                                today = DateTime.now
                                sunday = today - today.wday
                                prefix = 'http://libweb.cityofalbany.net/filepile/discovery_layer_exports/lbcc_marc_records_items.'
                                return prefix + sunday.strftime('%F') + '.mrc'
                            },
                        'file_prefix' => 'eg_lbcc',
                        'traject_configuration_files' => ['eg_lbcc.rb', 'eg_authorities.rb'],
                        },
                    'oclc' => {
                        'record_provider_facet' => 'OCLC',
                        'fetch_method' => 'ftp',
                        'file_prefix' => 'oclc',
                        'remote_server' => 'ftp2.oclc.org',
                        'credentials' => {
                            'user' => 'olx',
                            'password' => ENV['OCLC_PASSWORD']},
                        'traject_configuration_files' => ['oclc.rb'],
                        },
                    'jomi' => {
                        'record_provider_facet' => 'JoMI Surgical Videos',
                        'fetch_method' => 'http',
                        'fetch_url' => 'https://jomi.com/jomiRecords.mrc',
                        'file_prefix' => 'jomi',
                        'traject_configuration_files' => ['jomi.rb','proxy.rb'],
                        },
                }
            end
        end
    end
end
