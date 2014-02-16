class PostsController < ApplicationController
  include PostsHelper
  before_filter :check_for_mobile, :only => [:create, :comments, :destroy, :index, :update, :cnmedia]
  before_filter :signed_in_user
  before_filter :legal_user, :only => [:media, :thumbnail] #if user has rights to view individual posts
  before_filter :admin_user, :only => [:reports]
  before_filter :correct_user,  only: [:destroy]

  def create
    @post = current_user.posts.build(params[:post])
    if (!@post.subject)
      @post.subject = params[:subject]
    end
    if (params[:send_to_user] and @post.release)
        @post.privacy_option = "custom " + params[:send_to_user].to_s
    end
    if @post.save
      flash[:success] = "Review posted"
      #if request is a time capsule and request specify a receiver, enqueue a job that send the time capsule
      if (params[:send_to_user] and @post.release)
        Resque.enqueue_at(@post.release,SendTimeCapsuleToUserResqueJob, @post.user_id, params[:send_to_user], @post.id)
      end
      if (params[:close_minute_duration] and params[:close_minute_duration] > 0)
        valid_datetime = true
        begin
          should_sink_to_private = Time.now + params[:close_minute_duration] * 60
        rescue
          valid_datetime = false
        end
        if valid_datetime
          Resque.enqueue_at(should_sink_to_private, ClosePublicPostResqueJob, @post.id)
        end
      end
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
    unless (@post)
      @post = Post.find(params[:id])
    end
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

  #it's possible for non-owner to update post (in particular thumbs_up stat)
  #however only the post owner is allowed to update post topic and privacy_option
  def update
    puts "updating post"
    post = Post.find(params[:id])
    thumbs_up = params[:thumbs_up]
    update_result = true
    
    #if there is update to the post params    
    if params[:post]
      if current_user.id == post.user_id
        privacy_option = params[:post][:privacy_option]
        topic = params[:post][:topic]
        if topic
          update_result = post.update_attribute(:topic, topic)
        end
        if privacy_option
          update_result = post.update_attribute(:privacy_option, privacy_option)
        end
      end
    end

    #if purpose of update to update the number of thumbs_up
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

  def thumbnail
    if (@post.release and @post.release > DateTime.now)
      @post.file_url = "TimeCapsule"
      @post.thumbnail_url = "TimeCapsule"
    end

    if @post.file_url.start_with? "CN"
      redirect_to oss_thumbnail_url(@post).to_s
    else
      redirect_to s3_thumbnail_url(@post).to_s
    end
  end

  def media
    if (@post.release and @post.release > DateTime.now)
      @post.file_url = "TimeCapsule"
      @post.thumbnail_url = "TimeCapsule"
    end

    if @post.file_url.start_with? "CN"
      redirect_to oss_media_url(@post).to_s
    else
      redirect_to s3_media_url(@post).to_s
    end
  end

	def cnmedia
		imageData = params[:media]
		key = params[:key]
		thumbnailData = params[:thumbnailMedia]
		thumbnailKey = params[:thumbnailKey]
		mediaType = params[:mediaType]
		fileExt = params[:fileExt]

		img = StringIO.new(Base64.decode64(imageData))
    img.class.class_eval {attr_accessor :original_filename, :content_type}
    img.original_filename = key+fileExt
    img.content_type = mediaType

		thumb = StringIO.new(Base64.decode64(thumbnailData))
		thumb.class.class_eval {attr_accessor :original_filename, :content_type}
    thumb.original_filename = key+fileExt
    thumb.content_type = mediaType

		imgPath = Rails.root.join(img.original_filename)
		thumbPath = Rails.root.join(thumb.original_filename)

		File.open(imgPath, 'wb') do |file|
		  file.write(img.read)
			Aliyun::OSS::OSSObject.store(key, open(file), ENV['OSS_BUCKET'])
			#File.delete(file)
		end

		File.open(thumbPath, 'wb') do |file|
		  file.write(thumb.read)
			Aliyun::OSS::OSSObject.store(thumbnailKey, open(file), ENV['OSS_BUCKET'])
		end

		File.delete(imgPath) if File.exist?(imgPath)
		File.delete(thumbPath) if File.exist?(thumbPath)

		respond_to do |format|
      format.json { render json: "ok" }
		end

	end
  
  def reports
    post = Post.find(params[:id])
    @num_inappropriate = PostReport.where("post_id = :post_id AND category='Inappropriate'", :post_id => post.id).count
    @num_copyright = PostReport.where("post_id = :post_id AND category='Copyright content'", :post_id => post.id).count
    @reports = PostReport.where("post_id = :post_id", :post_id => post.id).paginate(:page => params[:page])
  end
  
  private 
    
    def legal_user
      if current_user.admin?
        @post = Post.find_by_id(params[:id])
      else
        posts = Post.allowed_to_view_posts(current_user).where(:id => params[:id])
        @post = posts.first
      end
      unauthorized_result if @post.nil?
    end
    
    def correct_user
      if current_user.admin?
        return
      end
      @post = current_user.posts.find_by_id(params[:id])
      unauthorized_result if @post.nil?
    end
end
