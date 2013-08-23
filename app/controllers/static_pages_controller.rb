class StaticPagesController < ApplicationController
  before_filter :check_for_mobile, :only => [:home]

  def home
    if signed_in?
      @post  = current_user.posts.build
      lat = params[:latitude]
      long = params[:longitude]
      levels = params[:levels]
      view_follow = params[:view_follow]
      nearby_radius = params[:nearby_radius]
      if not nearby_radius
        if levels
          nearby_radius = levels.first[:dist]
        else
          nearby_radius = 2000
        end
      end
      @notifications = current_user.notifications.where("created_at > :ten_days_back", ten_days_back: 10.days.ago);
      if (lat and long and levels)
        @post_feed_items = current_user.post_feed_nearby(lat,long, nearby_radius).paginate(page: params[:page])
        @unreleased_capsules_count = Post.number_of_unreleased_capsule_by_location(current_user,lat,long,levels)
      elsif (!view_follow)
        @post_feed_items = current_user.post_feed.paginate(page: params[:page])
        @unreleased_capsules_count = 0
      else
        @post_feed_items = current_user.post_follow_feed.paginate(page: params[:page])
        @unreleased_capsules_count = 0
      end
        
      respond_to do |format|
        format.html {}
        format.json { render json: { :post_list => @post_feed_items, 
                                     :notification_list => @notifications, 
                                     :user => current_user, 
                                     :unreleased_capsules_count => @unreleased_capsules_count } }
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
  
  def terms_of_use
    render :layout => false
  end

  def contact
  end
end
