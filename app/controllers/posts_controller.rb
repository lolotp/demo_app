class PostsController < ApplicationController
  before_filter :check_for_mobile, :only => [:create, :comments, :destroy, :index]
  before_filter :signed_in_user
  before_filter :correct_user,  only: :destroy

  def create
    puts "in create method of posts_controller"
    @post = current_user.posts.build(params[:post])
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

  def comments
    @post = Post.find_by_id (params[:id])
    @comments = @post.comments.paginate(page: params[:page])
    respond_to do |format|
      format.json { render json: @comments }
    end
  end
  
  private 
    def correct_user
      @post = current_user.posts.find_by_id(params[:id])
      unauthorized_result if @post.nil?
    end
end
