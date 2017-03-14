require 'test_helper'

class EdsConnectionTest < ActiveSupport::TestCase
    setup :initialize_vars

    test "When EDS Username is nil, the app will attempt IP authentication" do
        Rails.configuration.articles['username'] = nil
        @ip_conn = EdsConnection.new
        assert_not @ip_conn.using_uid_auth?
    end
    test "When EDS Username and password are both available in Rails.configuration, the app will attempt UID authentication" do
        Rails.configuration.articles['username'] = 'username'
        Rails.configuration.articles['password'] = 'password'
        conn = EdsConnection.new
        assert conn.using_uid_auth?
    end


    private
    def initialize_vars
        Rails.configuration.articles['username'] = nil
        @ip_conn = EdsConnection.new
    end


end
