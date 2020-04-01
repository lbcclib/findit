require 'net/ftp'
require 'net/http'
require 'time'

module FindIt
    module Data
        module Fetch

            # Fetches a MARC file given the URL and the prefix you'd like to save it to
            def fetch_http urls, prefix, opts = {}
                if urls.kind_of? Proc
                    urls_to_fetch = [urls.call].flatten(1)
	            else
                    urls_to_fetch = [urls].flatten(1)
	            end
                files_written = []
                filename = Rails.root.join('lib', 'tasks', 'data', 'new', prefix + '_' + date_downloaded + '.mrc')
                if File.exist? filename
                    File.delete filename
                end
                urls_to_fetch.each do |url|
	                uri = URI.parse url
                    if opts.key? 'user'
                        uri.http_basic_authentication = opts['user'], opts['pass']
                    end
                    open(filename, 'ab') do |file|
                        IO.copy_stream(open(uri, 'rb'), file)
                    end
                    files_written << (filename)
                end
                return files_written.uniq
            end

            def fetch_ftp server, prefix, credentials, opts = {}
                files_written = []
                ftp = Net::FTP.new server
	            ftp.passive = true
                ftp.login credentials['user'], credentials['password']
                files = ftp.chdir('metacoll/out/ongoing/new')
                files_written += fetch_latest_files_by_ftp ftp, 'new', prefix
                files = ftp.chdir('../updates')
                files_written += fetch_latest_files_by_ftp ftp, 'update', prefix
                files = ftp.chdir('../deletes')
                files_written += fetch_latest_files_by_ftp ftp, 'delete', prefix
                return files_written
                ftp.close
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
                        filename = directory + '/' + prefix + '_' + date_downloaded + '.mrc'
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
