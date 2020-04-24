require 'net/ftp'
require 'net/http'
require 'time'

module FindIt
    module Data
        module Fetch

            # Fetches a MARC file over http given the config
            def http config
                if config['fetch_url'].kind_of? Proc
                    urls_to_fetch = [config['fetch_url'].call].flatten(1)
	            else
                    urls_to_fetch = [config['fetch_url']].flatten(1)
	            end
                files_written = []
                filename = Rails.root.join('lib', 'tasks', 'data', 'new', config['file_prefix'] + '_' + date_downloaded + '.mrc')
                if File.exist? filename
                    File.delete filename
                end
                urls_to_fetch.each do |url|
                    uri = URI.parse url
                    open(filename, 'ab') do |file|
                        if config.key? 'user'
                            IO.copy_stream(open(uri, :http_basic_authentication => [config['user'], config['pass']]), file)
			            else
                            IO.copy_stream(open(uri, 'rb'), file)
                        end
                    end
                    files_written << (filename)
                end
                return files_written.uniq
            end

            def ftp config
                files_written = []
                ftp = Net::FTP.new config['server']
	            ftp.passive = true
                ftp.login config['user'], config['pass']
                files = ftp.chdir('metacoll/out/ongoing/new')
                files_written += fetch_latest_files_by_ftp ftp, 'new', config['file_prefix']
                files = ftp.chdir('../updates')
                files_written += fetch_latest_files_by_ftp ftp, 'update', config['file_prefix']
                #files = ftp.chdir('../deletes')
                #files_written += fetch_latest_files_by_ftp ftp, 'delete', config['file_prefix']
                ftp.close
                return files_written
            end

            private
            def date_downloaded
                return DateTime.now.strftime('%F-%H-%M-%S')
            end

            def fetch_latest_files_by_ftp ftp, directory, prefix
                files_written = []
                files = ftp.nlst('*.mrc')
                files.each do |file|
                    if (Time.now - (7*24*60*60)) < (ftp.mtime file)
                        filename = Rails.root.join('lib', 'tasks', 'data', directory, prefix + '_' + date_downloaded + '.mrc').to_s
                        puts file + ' is saving as ' + filename
                        ftp.getbinaryfile(file, filename)
                        files_written << filename
                    end
                end
                return files_written
            end
        end
    end
end
