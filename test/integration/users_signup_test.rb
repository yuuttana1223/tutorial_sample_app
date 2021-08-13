require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    # before_count = User.count
    # post users_path, ...
    # after_count  = User.count
    # assert_equal before_count, after_count
    # 上と等価
    assert_no_difference "User.count" do
      post signup_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template "users/new"
    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
    assert_select "div.alert"
    assert_select "form[action='/signup']"
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, params: { user: { name: "Example User",
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password" } }
    end
    # 配信されたメッセージがきっかり1つ
    assert_equal 1, ActionMailer::Base.deliveries.size
    # assignsメソッドを使うと対応するアクション内の@userにアクセスできる
    user = assigns(:user)
    assert_not user.is_activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: "wrong")
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.is_activated?
    follow_redirect!
    assert_template "users/show"
    assert is_logged_in?
    # 次のページに遷移した瞬間に文字だけ表示してflashはcookieから消える
    assert_not flash.empty?
  end
end
