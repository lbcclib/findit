# frozen_string_literal: true

require 'net/ftp'
require 'net/http'
require 'time'

module FindIt
  module Data
    # Fetches metadata from external sources
    module Fetch
      def http(config)
        urls_to_fetch = if config['fetch_url'].is_a? Proc
                          [config['fetch_url'].call].flatten(1)
                        else
                          [config['fetch_url']].flatten(1)
                        end
        files_written = []
        filename = Rails.root.join('lib', 'tasks', 'data', 'new', "#{config['file_prefix']}_#{date_downloaded}.mrc")
        File.delete filename if File.exist? filename
        urls_to_fetch.each do |url|
          uri = URI.parse url
          File.open(filename, 'ab') do |file|
            if config.key? 'user'
              IO.copy_stream(uri.open(http_basic_authentication: [config['user'], config['pass']]), file)
            else
              IO.copy_stream(uri.open, file)
            end
          end
          files_written << filename
        end
        files_written.uniq
      end

      def ftp(config)
        files_written = []
        ftp = Net::FTP.new config['server']
        ftp.passive = true
        ftp.login config['user'], config['pass']
        config['directories'].each do |directory|
          ftp.chdir directory[:remote]
          files_written += fetch_latest_files_by_ftp ftp, directory[:local], config['file_prefix']
        end
        ftp.close
        files_written
      end

      private

      def date_downloaded
        DateTime.now.strftime('%F-%H-%M-%S')
      end

      def fetch_latest_files_by_ftp(ftp, directory, prefix)
        files_written = []
        files = ftp.nlst('*.mrc')
        files.each do |file|
          next unless (Time.zone.now - (7 * 24 * 60 * 60)) < (ftp.mtime file)

          filename = Rails.root.join('lib', 'tasks', 'data', directory, "#{prefix}_#{date_downloaded}.mrc").to_s
          puts "#{file} is saving as #{filename}"
          ftp.getbinaryfile(file, filename)
          files_written << filename
        end
        files_written
      end
    end
  end
end
