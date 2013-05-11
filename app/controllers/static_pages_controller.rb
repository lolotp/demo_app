class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @post  = current_user.posts.build
      lat = params[:latitude]
      long = params[:longitude]
      if (lat and long)
        @feed_items = current_user.feed_by_social_radius(lat,long).paginate(page: params[:page])
      else
        @feed_items = current_user.feed.paginate(page: params[:page])
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
