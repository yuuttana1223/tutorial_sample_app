require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  # before_count = User.count
  # post users_path, ...
  # after_count  = User.count
  # assert_equal before_count, after_count
  # 上と等価
  test "invalid signup information" do
    get signup_path
    assert_no_difference "User.count" do
      post signup_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template "users/new"
    assert_select "div#error_explanation"
    assert_select "div.alert"
    assert_select "form[action='/signup']"
  end

  test "valid signup information" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, params: { user: { name: "Example User",
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template "users/show"
    assert is_logged_in?
    # 次のページに遷移した瞬間に文字だけ表示してflashはcookieから消える
    assert_not flash.empty?
  end
end