class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    # !user.is_activated?は二回目は無効にするため
    if user && !user.is_activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
