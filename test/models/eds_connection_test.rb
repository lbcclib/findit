require 'test_helper'

class EdsConnectionTest < ActiveSupport::TestCase
    test "When EDS Username is nil, the app will attempt IP authentication" do
        Rails.configuration.articles['username'] = nil
        conn = EdsConnection.new
        assert_not conn.using_uid_auth?
    end
end
