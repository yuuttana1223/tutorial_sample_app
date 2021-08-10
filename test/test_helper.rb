ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper
  # Add more helper methods to be used by all tests here...

  # テスト時に使えるメソッド
  def is_logged_in?
    !session[:user_id].nil?
  end

  def log_in_as(user)
    session[:user_id] = user.id
  end

  # 統合テストではsessionを直接取り扱うことができない
  class ActionDispatch::IntegrationTest

    # テストユーザーとしてログインする
    def log_in_as(user, password: "password", remember_me: "1")
      post login_path, params: { session: { email: user.email,
                                           password: password,
                                           remember_me: remember_me } }
    end
  end
end
