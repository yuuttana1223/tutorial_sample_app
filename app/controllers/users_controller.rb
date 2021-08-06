class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    # @user = User.new(name: "Foo Bar", email: "foo@invalid",
    #   password: "foo", password_confirmation: "bar")
    # @user = User.new(params[:user])
    @user = User.new(user_params)
    if @user.save
      # ユーザー登録と同時にログイン
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
