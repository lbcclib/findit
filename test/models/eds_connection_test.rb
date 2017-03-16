require 'test_helper'
require 'securerandom'
require 'pp'

class TestConnectionHandler < EDSApi::ConnectionHandler
    def initialize
        @session_token = SecureRandom.hex
        @auth_token = SecureRandom.hex
    end
end

class TestEdsConnection < EdsConnection
    def initialize
        super
        @raw_connection = TestConnectionHandler.new
    end
end

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

    test "When EDS password is unavailable in Rails.configuration, the app will attempt IP authentication" do
        Rails.configuration.articles['username'] = 'username'
        Rails.configuration.articles.delete('password')
        conn = EdsConnection.new
        assert_not conn.using_uid_auth?
    end

    test "When EDS username is unavailable in Rails.configuration, the app will attempt IP authentication" do
        Rails.configuration.articles.delete('username')
        Rails.configuration.articles['password'] = 'password'
        conn = EdsConnection.new
        assert_not conn.using_uid_auth?
    end

    test "UID-authenticated EDS Connection reports that it is ready when both session token and auth token are available" do
        Rails.configuration.articles['username'] = 'username'
        Rails.configuration.articles['password'] = 'password'
        conn = TestEdsConnection.new
        assert conn.ready?
    end

    test "IP-authenticated EDS Connection reports that it is ready when both session token and auth token are available" do
        Rails.configuration.articles.delete('username')
        Rails.configuration.articles['password'] = 'password'
        conn = TestEdsConnection.new
        assert conn.ready?
    end

    private
    def initialize_vars
        Rails.configuration.articles['username'] = nil
        @ip_conn = EdsConnection.new
    end


end
