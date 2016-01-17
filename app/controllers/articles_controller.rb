class ArticlesController < ApplicationController
    require 'nokogiri'
    require 'open-uri'
    require 'ruby_eds.rb'
    require 'uri'

    include RubyEDS

    PROXY_PREFIX = 'http://ezproxy.libweb.linnbenton.edu:2048/login?url='



    def show
        raw_response = retrieve(params[:db], params[:id], session[:article_session_token], session[:article_user_token])
        doc = Nokogiri::XML(raw_response.body)
        doc.remove_namespaces!
        record = doc.at_xpath('.//Record')

        @document = {}
        
        @document[:title] = record.xpath('.//RecordInfo/BibRecord/BibEntity/Titles/Title/TitleFull').text
        @document[:journal] = record.xpath('.//IsPartOf/BibEntity/Titles/Title/TitleFull').text
        @document[:url] = PROXY_PREFIX + record.xpath('./PLink').text
        @document[:abstract] = record.xpath('./Items/Item[Name/text()="Abstract"]/Data').text
        @document[:year] = record.xpath('.//Date[Type/text()="published"]/Y').text
        @document[:type] = 'Article'
        @document[:authors] = []
            authors = record.xpath('.//PersonEntity')
            authors.each do |author|
                @document[:authors].push(author.xpath('.//NameFull').text)
            end

        
    end
end
