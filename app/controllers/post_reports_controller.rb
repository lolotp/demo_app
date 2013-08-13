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

    @reported_post_ids = PostReport.recently_reported_posts_ids(from_time).paginate(:page => params[:page])
    @posts = Post.unscoped.select(" posts.*, post_bans.id as ban_id").joins("INNER JOIN (SELECT DISTINCT ON (post_id) post_id, created_at FROM post_reports WHERE created_at > '" + from_time.to_s + "') as post_reports ON post_reports.post_id = posts.id").joins("FULL OUTER JOIN post_bans ON posts.id = post_bans.post_id").order("post_reports.created_at DESC").paginate(:page => params[:page])
    #@posts = Post.select("posts.*, post_bans.id as ban_id").joins(@reported_post_ids)#.joins("FULL OUTER JOIN post_bans ON post_bans.post_id = posts.id")#.where(:id => @reported_post_ids).paginate(:page => params[:page])
    
  end
end
