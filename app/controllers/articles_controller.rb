class ArticlesController < ApplicationController
    require 'nokogiri'
    require 'open-uri'
    require 'ruby_eds.rb'
    require 'uri'

    include RubyEDS


    def show
        raw_response = retrieve(params[:db], params[:id], session[:article_session_token], session[:article_user_token])
        doc = Nokogiri::XML(raw_response.body)
        doc.remove_namespaces!

        @document = {}
        
        @document[:title] = doc.xpath('.//Items/Item[Label/text()="Title"]/Data').text
        
    end
end
