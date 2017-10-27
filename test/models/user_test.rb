require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users
  test "can access user's email addresses" do
    User.all.each do |user|
      assert_not_empty user.email
    end
  end
  test "can access azariah's email addresses" do
    assert_not_empty users(:azariah).email
  end
end
