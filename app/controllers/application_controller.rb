class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  def hello
    render html: "hello, world"
  end

  # コントローラの場合はprivateは継承先でも参照できる(コントローラー外部からアクセスさせないためのprivate)
  private

  def logged_in_user
    unless logged_in?
      # ログインしていない場合に行こうとしていたurlを保存
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
end
