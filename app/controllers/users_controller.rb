require 'aws-sdk'
class UsersController < ApplicationController
  include UsersHelper
  before_filter :check_for_mobile, :only => [:create, :friends, :show, :find_users, :relation, :amazon_s3_temporary_credentials, :requested_friends, :update, :details, :followees, :activate, :send_activation_code]
  before_filter :signed_in_user, only: [:index, :show, :edit, :update, :destroy, :friends, :amazon_s3_temporary_credentials, :requested_friends, :friends, :details, :avatar]
  before_filter :correct_user,   only: [:edit, :update, :amazon_s3_temporary_credentials, :requested_friends]
  before_filter :admin_user, only: :destroy
  

  def new
    @user = User.new
  end
  
  def show
    @user = User.find_by_id(params[:id])
    if (current_user == @user or current_user.admin?)
      @posts = @user.posts.paginate(page: params[:page])
    elsif (current_user.friend?(@user))
      @posts = @user.posts.where("privacy_option != 'private' AND ban_count < 2").paginate(page: params[:page])
    else
      @posts = @user.posts.where("privacy_option = 'public' AND ban_count < 2").paginate(page: params[:page])
    end

    respond_to do |format|
      format.html {}
      format.json { render json: @posts }
    end
  end
  
  def details
    @user = User.find_by_id(params[:id])
    respond_to do |format|
      format.json { render json: @user }
    end
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      phone_number = params[:phone_number]
      Resque.enqueue(SendUserActivationCodeResqueJob, @user.id, phone_number)
      respond_to do |format|
        format.json { render json: { :name => @user.name, :user => @user } }
        format.html { redirect_to root_path }
      end        
    else
      respond_to do |format|
        format.json { render json: "Error registering user: " + @user.errors.full_messages.first, :status => 404 }
        format.html { render 'new' }
      end
    end
  end

  def send_activation_code
    user = User.find(params[:id])
    if user && user.authenticate(params[:password])
      phone_number = params[:phone_number]
      Resque.enqueue(SendUserActivationCodeResqueJob, user.id, phone_number)
    end
    respond_to do |format|
      format.json {render json:"ok"}
    end
  end  

  def edit
  end

  def update
    if (params[:user][:password])
      update_result = @user.update_attributes(params[:user])
    else
      update_result = @user.update_nonpassword_attributes(params[:user])
    end
    
    if update_result 
      flash[:success] = "Profile updated"
      sign_in @user
      if mobile_device?
        respond_to do |format|
          format.json { render json: "ok" }
        end
      else
        redirect_to @user
      end
    else
      if mobile_device?
        respond_to do |format|
          format.json { render json: @user.errors, :status => 400 }
        end
      else
        render 'edit'
      end
    end
  end
  
  def index
    @users = User.paginate(page: params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end
  
  def friends
    @title = "Friends"
    @user = User.find(params[:id])
    @users = @user.friends#.paginate(page: params[:page])
    respond_to do |format|
      format.html { render 'show_friends' }
      format.json { render json: @users }
    end   
  end

  def requested_friends
		@requested_friends = User.select("users.*, friendships.id as friendship_id").joins("INNER JOIN friendships ON users.id = friendships.friend_id").where("friendships.user_id=:user_id AND friendships.status = 'requested'", :user_id => params[:id])
    respond_to do |format|
      format.json { render json: @requested_friends }
    end
  end

	def followees
		@user = User.find(params[:id])
    followee_user_ids = "SELECT followee_id FROM follows
                         WHERE user_id = :user_id"
    @users = User.where("public = true OR id IN (#{followee_user_ids})",user_id: @user.id)
		#@users#.paginate(page: params[:page])
		respond_to do |format|
			format.json { render json: @users }
		end
	end
  
  def find_users
    search_string = params[:search_string].downcase
    @found_users = User.find_matched_users(search_string)#.paginate(page: params[:page])
    respond_to do |format|
      format.json {render json: @found_users}
    end
  end

  def show_mobile
    respond_to do |format|
      ret_str = ""
      init = true
      current_user.microposts.each do |s|
        if init
          ret_str = s[:content]
          init = false
        else
          ret_str = ret_str + "#" + s[:content]
        end
      end 
      format.html { render :text => ret_str }
    end
  end
  
  def relation
    other_user_id = params[:other_user]
    @friendship = current_user.friendships.find_by_friend_id(other_user_id)
    respond_to do |format|
      if (@friendship)
        format.json { render json: {:status => @friendship.status, :id => @friendship.id } }
      else
        format.json { render json: {:status => @friendship, :id => @friendship } }
      end
    end
  end

	def relation_follow
		other_user_id = params[:other_user]
		@follow = current_user.follows.find_by_followee_id(other_user_id)
		respond_to do |format|
			format.json { render json: { :follow => @follow } }
		end
	end

  def amazon_s3_temporary_credentials
    my_access_key_id = ENV['S3_KEY']
    my_secret_key = ENV['S3_SECRET']
    
    resource = params[:resource]

    AWS.config({
      :access_key_id => my_access_key_id,
      :secret_access_key => my_secret_key
    })
    sts = AWS::STS.new()
    policy = AWS::STS::Policy.new
    policy.allow(
      :actions => ['s3:PutObject','s3:GetObject'],
      :resources => "arn:aws:s3:::#{resource}")
  
    session = sts.new_federated_session(
      current_user.email,
      :policy => policy,
      :duration => 900)

    respond_to do |format|
      format.json { render json: session.credentials }
    end
  end

  def avatar
    @user = User.find(params[:id])
    redirect_to avatar_s3_url(@user).to_s
  end

  def activate
    user = User.find(params[:id])
    code = params[:confirmation_code].to_i
    if user.confirmation_code == 0 or user.confirmation_code == code.to_i
      user.update_attribute(:confirmation_code, 0)
      respond_to do |format|
        format.json { render json: "ok" }
      end
    else
      respond_to do |format|
        format.json { render json: "Invalid code" + code.to_s, :status => 400 }
      end
    end
  end
  
  private

    def correct_user
      @user = User.find_by_id(params[:id])
      if (!@user or !current_user?(@user))
        unauthorized_result
      end
    end
end
