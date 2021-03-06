module SessionsHelper
  def log_in(user)
    # Sessionsコントローラとは無関係
    session[:user_id] = user.id
  end

  def remember(user)
    user.remember
    # permanent(永続化).signed(暗号化)
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user?(user)
    user == current_user
  end

  def current_user
    # user_idに代入した結果があれば
    if (user_id = session[:user_id])
      # @current_user = @current_user || User.find_by(id: user_id)
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      # raise # テストがパスすれば、この部分がテストされていないことがわかる(RuntimeError例外を発生させる)
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    # session自体は削除していない。sessionの中の一部(:user_id)だけを削除
    session.delete(:user_id)
    # リダイレクトを直接発行しなかった場合のため万が一
    @current_user = nil
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    # request.original_urlでリクエスト先が取得
    session[:forwarding_url] = request.original_url if request.get?
  end

  # 記憶したURL (もしくはデフォルト値) にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
end
