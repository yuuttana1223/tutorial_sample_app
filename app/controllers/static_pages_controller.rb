class StaticPagesController < ApplicationController
  def home
    # 1行のときは後置if文、2行以上のときは前置if文を使うのがRubyの慣習
    # @micropost = current_user.microposts.build if logged_in?
    if logged_in?
      @micropost = current_user.microposts.build
      # current_user.micropostsと現状同じ意味
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
