# frozen_string_literal: true

require 'net/ftp'
require 'net/http'
require 'time'

module FindIt
  module Data
    # Fetches metadata from external sources
    module Fetch
      def http(config)
        urls_to_fetch = handle_fetch_url config['fetch_url']
        files_written = []
        filename = Rails.root.join('lib', 'tasks', 'data', 'new', "#{config['file_prefix']}_#{date_downloaded}.mrc")
        File.delete filename if File.exist? filename
        urls_to_fetch.each do |url|
          fetch_file_by_http url: url, filename: filename, config: config
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

      def fetch_file_by_http(url:, filename:, config:)
        uri = URI.parse url
        remote_open = if config.key? 'user'
                        uri.open(http_basic_authentication: [config['user'], config['pass']])
                      else
                        uri.open
                      end
        File.open(filename, 'ab') { |file| IO.copy_stream(remote_open, file) }
      end

      def fetch_latest_files_by_ftp(ftp, directory, prefix)
        files_written = []
        files = ftp.nlst('*.mrc')
        files.each do |file|
          next unless (Time.zone.now - (7 * 24 * 60 * 60)) < (ftp.mtime file)

          filename = Rails.root.join('lib', 'tasks', 'data', directory, "#{prefix}_#{date_downloaded}.mrc").to_s
          ftp.getbinaryfile(file, filename)
          files_written << filename
        end
        files_written
      end

      def handle_fetch_url(url)
        if url.is_a? Proc
          [url.call].flatten(1)
        else
          [url].flatten(1)
        end
      end

      def date_downloaded
        DateTime.now.strftime('%F-%H-%M-%S')
      end
    end
  end
end
