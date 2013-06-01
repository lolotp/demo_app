class StaticPagesController < ApplicationController
  before_filter :check_for_mobile, :only => [:home]

  def home
    if signed_in?
      @post  = current_user.posts.build
      lat = params[:latitude]
      long = params[:longitude]
      levels = params[:levels]
      if (lat and long and levels)
        @feed_items = current_user.feed_by_social_radius(lat,long, params[:levels]).paginate(page: params[:page])
      else
        @feed_items = current_user.feed.paginate(page: params[:page])
      end
        
      respond_to do |format|
        format.html {}
        format.json { render json: { :post_list => @feed_items, :user => current_user } }
      end  
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
