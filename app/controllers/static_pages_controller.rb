class StaticPagesController < ApplicationController
  before_filter :check_for_mobile, :only => [:home]

  def home
    if signed_in?
      @post  = current_user.posts.build
      lat = params[:latitude]
      long = params[:longitude]
      levels = params[:levels]
      if (lat and long and levels)
        @post_feed_items = current_user.post_feed_by_social_radius(lat,long, levels).paginate(page: params[:page])
        @landmark_feed_items = Landmark.feed_by_social_radius(lat,long, levels).paginate(page: params[:landmark_page])
      else
        @post_feed_items = current_user.post_feed.paginate(page: params[:page])
        @landmark_feed_items = Landmark.feed_by_social_radius(lat,long, []).paginate(page: params[:landmark_page])
      end
        
      respond_to do |format|
        format.html {}
        format.json { render json: { :post_list => @post_feed_items, :landmark_list => @landmark_feed_items, :user => current_user} }
      end  
    else
      respond_to do |format|
        format.html {}
        format.json { render json:  "Unauthorized", :status => 401 }      
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
