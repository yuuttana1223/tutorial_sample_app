class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.where(is_activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])

    # renderやredirect_toの戻り値がtrueなのを利用
    # returnは二重レンダリングの問題を回避するため
    # &&だと優先度の都合で駄目
    # redirect_to root_url unless @user.is_activated?
    redirect_to root_url and return unless @user.is_activated?
  end

  def new
    @user = User.new
  end

  def create
    # @user = User.new(name: "Foo Bar", email: "foo@invalid",
    #   password: "foo", password_confirmation: "bar")
    # 上と同じ意味
    # @user = User.new(params[:user])
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
      # ユーザー登録と同時にログイン アカウント有効化を実装するうえでは無意味な動作
      # log_in @user
      # flash[:success] = "Welcome to the Sample App!"
      # redirect_to @user
    else
      render :new
    end
  end

  def edit
    # correct_userで@userを定義している
    # @user = User.find(params[:id])
  end

  def update
    # @user = User.find(params[:id])
    # updateはupdate_attributesのエイリアス
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render "show_follow"
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render "show_follow"
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.is_admin?
  end
end
