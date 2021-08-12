class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      log_in @user
      # チェックボックスがオンのときに'1'になり、オフのときに'0'
      params[:session][:remember_me] == "1" ? remember(@user) : forget(@user)
      # ログインしていないユーザーが編集ページにアクセスしようとしていたなら、ユーザーがログインした後にはその編集ページにリダイレクトされる
      redirect_back_or @user
    else
      flash.now[:danger] = "Invalid email/password combination" # 本当は正しくない
      render :new
    end
  end

  def destroy
    # 複数のブラウザでログインしているときのため
    log_out if logged_in?
    redirect_to root_url
  end
end
