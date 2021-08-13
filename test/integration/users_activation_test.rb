require "test_helper"

class UsersActivationTest < ActionDispatch::IntegrationTest
  def setup
    @activated_user = users(:michael)
    @non_activated_user = users(:stephan)
  end

  test "index only activated user" do
    log_in_as(@activated_user)
    get users_path
    assert_select "a[href=?]", user_path(@activated_user)
    assert_select "a[href=?]", user_path(@non_activated_user), count: 0
  end

  test "show only activated user" do
    log_in_as(@activated_user)
    get user_path(@non_activated_user)
    assert_redirected_to root_url
  end
end
