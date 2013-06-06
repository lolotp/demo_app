class PostsController < ApplicationController
  before_filter :check_for_mobile, :only => [:create, :comments]
  before_filter :signed_in_user 
  before_filter :correct_user,   only: :destroy

  def create
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
      @feed_items = []
      respond_to do |format|
        format.html { render 'static_pages/home' }
        format.json { render json:@post.errors.full_messages.first, :status => 400 }
      end
    end

  end

  def destroy
    @post.destroy
    redirect_to root_url
  end

  def comments
    @post = Post.find_by_id (params[:id])
    @comments = @post.comments
    respond_to do |format|
      format.json { render json: @comments }
    end
  end
  
  private 
    def correct_user
      @post = current_user.posts.find_by_id(params[:id])
      redirect_to root_url if @post.nil?
    end
end
