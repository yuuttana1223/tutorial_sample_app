module SessionsHelper
  def log_in(user)
    # Sessionsコントローラとは無関係
    session[:user_id] = user.id
  end

  def current_user
    if session[:user_id]
      # if @current_user.nil?
      #   @current_user = User.find_by(id: session[:user_id])
      # else
      #   @current_user
      # end

      # @current_user = @current_user || User.find_by(id: session[:user_id])

      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    # session自体は削除していない。sessionの中の一部(:user_id)だけを削除
    session.delete(:user_id)
    @current_user = nil
  end
end
