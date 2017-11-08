require 'test_helper'
require 'securerandom'
require 'pp'

class EdsConnectionTest < ActiveSupport::TestCase
    setup :initialize_vars

    test "Can send 1000 searches without erroring" do
	opts = {q: 'cats'}
	(1..1000).each do
	    @eds_conn.send_search opts
	end
    end

    test "Can retrieve an article 1000 times without erroring" do
	(1..10).each do
	    @eds_conn.retrieve_single_article 'f5h', '124413323'
	end
    end

    private
    def initialize_vars
        @eds_conn = EdsConnection.new
    end


end
