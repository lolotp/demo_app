class PostReportsController < ApplicationController
  before_filter :check_for_mobile, :only => [:create]
  before_filter :signed_in_user
  before_filter :admin_user, :only => [:index]
  def create
    post_report = current_user.post_reports.build(params[:post_report])
    post_report.post_id = params[:post_id]
    respond_to do |format|
      if (post_report.save)
        format.json { render json:"ok" }
      else
        format.json { render json: post_report.errors.full_messages.first, :status => 400 }
      end
    end
  end

  def index
    from_time = params[:from_time]
    if not from_time
      from_time = 10.days.ago
    end

    @reported_post_ids = PostReport.recently_reported_posts_ids(from_time)
    @posts = Post.select("posts.*, post_bans.id as ban_id").joins("FULL OUTER JOIN post_bans ON post_bans.post_id = posts.id").where(:id => @reported_post_ids).paginate(:page => params[:page])
    
  end
end
