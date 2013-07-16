require 'aws-sdk'
class UsersController < ApplicationController
  before_filter :check_for_mobile, :only => [:create, :friends, :show, :find_users, :relation, :amazon_s3_temporary_credentials, :requested_friends]
  before_filter :signed_in_user, only: [:index, :show, :edit, :update, :destroy, :friends, :amazon_s3_temporary_credentials, :requested_friends, :friends]
  before_filter :correct_user,   only: [:edit, :update, :amazon_s3_temporary_credentials, :requested_friends]
  before_filter :admin_user, only: :destroy
  

  def new
    @user = User.new
  end
  
  def show
    @user = User.find_by_id(params[:id])
    @posts = @user.posts.paginate(page: params[:page])
    respond_to do |format|
      format.html {}
      format.json { render json: @posts }
    end
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to root_path        
    else
      respond_to do |format|
        format.json { render json: "Error registering user: " + @user.errors.full_messages.first, :status => 404 }
        format.html { render 'new' }
      end
    end
  end
  
  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
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
    @users = @user.friends.paginate(page: params[:page])
    respond_to do |format|
      format.html { render 'show_friends' }
      format.json { render json: @users }
    end   
  end

  def requested_friends
    @requested_friends = @user.requested_friends.paginate(page: params[:page])
    respond_to do |format|
      format.json { render json: @requested_friends }
    end
  end

	def followees
		@user = User.find(params[:id])
		@users = @user.followees.paginate(page: params[:page])
		respond_to do |format|
			format.json { render json: @users }
		end
	end
  
  def find_users
    search_string = params[:search_string]
    @found_users = User.find_matched_users(search_string).paginate(page: params[:page])
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

  def amazon_s3_temporary_credentials
    my_access_key_id = 'AKIAJVYGWBMHL24XPXYA'
    my_secret_key = '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'
    resource = params[:resource]

    AWS.config({
      :access_key_id => my_access_key_id,
      :secret_access_key => my_secret_key
    })
    sts = AWS::STS.new()
    policy = AWS::STS::Policy.new
    policy.allow(
      :actions => ['s3:PutObject','s3:GetObject','s3:ListObject'],
      :resources => "arn:aws:s3:::#{resource}")
  
    session = sts.new_federated_session(
      current_user.email,
      :policy => policy,
      :duration => 2*60*60)

    respond_to do |format|
      format.json { render json: session.credentials }
    end
  end
  
  private

    def correct_user
      @user = User.find_by_id(params[:id])
      if (!@user or !current_user?(@user))
        unauthorized_result
      end
    end
    
    def admin_user
      unauthorized_result unless current_user.admin?
    end
end
