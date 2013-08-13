class PostsController < ApplicationController
  before_filter :check_for_mobile, :only => [:create, :comments, :destroy, :index, :update]
  before_filter :signed_in_user
  before_filter :admin_user, :only => [:reports]
  before_filter :correct_user,  only: :destroy

  def create
    @post = current_user.posts.build(params[:post])
    if (!@post.subject)
      @post.subject = params[:subject]
    end
    if @post.save
      flash[:success] = "Review posted"
      if mobile_device?
        respond_to do |format|
          format.json { render json:"ok" }
        end
      else
        redirect_to root_url
      end
    else
      @post_feed_items = []
      respond_to do |format|
        format.html { render 'static_pages/home' }
        format.json { render json:@post.errors.full_messages.first, :status => 400 }
      end
    end

  end

  def index
    ids = params[:ids]
    if (ids)
      @posts = Post.allowed_to_view_posts(current_user).where(:id => ids)
    else
      @posts = Post.where("").paginate(:page => params[:page])
    end
    respond_to do |format|
      format.json { render json:@posts }
    end
  end

  def destroy
    @post.destroy
    if mobile_device?
      respond_to do |format|
        if (@post.destroyed?)
          format.json { render json: "ok" }
        else
          format.json { render json: "error", :status => 400 }
        end  
      end
    else
      redirect_to root_url
    end
  end

  def update
    post = Post.find(params[:id])
    thumbs_up = params[:thumbs_up]
    update_result = true
    if current_user.id == post.user_id
      privacy_option = params[:post][:privacy_option]
      update_result = post.update_attribute(:privacy_option, privacy_option)
    end
    if thumbs_up
      update_result = update_result and post.increment!(:like_count)
    end
    respond_to do |format|
      if update_result
        format.json { render json: "ok" }
      else
        format.json { render json: post.errors.full_messages.first, :status => 400 }
      end
    end
  end

  def comments
    @post = Post.find_by_id (params[:id])
    @comments = @post.comments.paginate(page: params[:page])
    respond_to do |format|
      format.json { render json: @comments }
    end
  end
  
  def reports
    post = Post.find(params[:id])
    @num_inappropriate = PostReport.where("post_id = :post_id AND category='Inappropirate'", :post_id => post.id).count
    @num_copyright = PostReport.where("post_id = :post_id AND category='Copyright content'", :post_id => post.id).count
    @reports = PostReport.where("post_id = :post_id", :post_id => post.id).paginate(:page => params[:page])
  end
  
  private 
    def correct_user
      if current_user.admin?
        return
      end
      @post = current_user.posts.find_by_id(params[:id])
      unauthorized_result if @post.nil?
    end
end
