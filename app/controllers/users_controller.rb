require 'aws-sdk'
class UsersController < ApplicationController
  include UsersHelper

  before_filter :check_for_mobile, :only => [:create, :friends, :show, :find_users, :relation, :amazon_s3_temporary_credentials, 
                                             :requested_friends, :update, :details, :followees, :activate, :send_activation_code, 
                                             :user_with_email, :users_and_users_relation_with_emails, :send_reset_password_email, :aliyun_oss_credentials]
  before_filter :signed_in_user, only: [:index, :show, :edit, :update, :destroy, :friends, :amazon_s3_temporary_credentials, 
                                        :requested_friends, :friends, :details, :avatar, :user_with_email, :users_and_users_relation_with_emails,
                                        :aliyun_oss_credentials]

  before_filter :correct_user,   only: [:edit, :update, :amazon_s3_temporary_credentials, :requested_friends, :aliyun_oss_credentials]
  before_filter :admin_user, only: :destroy
  

  def new
    @user = User.new
  end
  
  def show
    @user = User.find_by_id(params[:id])
    if (current_user == @user or current_user.admin?)
      @posts = @user.posts.paginate(page: params[:page])
    elsif (current_user.friend?(@user))
      @posts = @user.posts.where("(privacy_option = 'friends' OR privacy_option = 'public') AND ban_count < 2").paginate(page: params[:page])
    else
      @posts = @user.posts.where("privacy_option = 'public' AND ban_count < 2").paginate(page: params[:page])
    end

    respond_to do |format|
      format.html {}
      format.json { render json: @posts, :current_user_id => current_user.id }
    end
  end
  
  def user_with_email
    @user = User.find_by_email(params[:email])
    respond_to do |format|
      format.json { render json: @user }
    end
  end

  def users_and_users_relation_with_emails
    email_list = params[:email_list]
    @user = User.find(params[:id])
    @users = User.select("users.*, friendships.status as friend_status").joins("LEFT OUTER JOIN friendships ON (users.id = friendships.user_id AND friendships.friend_id = " + params[:id].to_s + ")").where(:email => email_list)
    respond_to do |format|
      format.json { render json: @users, :include_fields => [:friend_status] }
    end
  end

  def details
    if (params[:id])
      @user = User.find_by_id(params[:id])
    end

    respond_to do |format|
      format.json { render json: @user }
    end
  end

  def send_reset_password_email
    user = User.find_by_email(params[:email])
    respond_to do |format|
      if user
        begin        
          Resque.enqueue(SendResetPasswordEmailResqueJob, user.id)
        rescue
          logger.debug "failed to enqueue resque job"
        end
        format.json { render json:"ok" }
      else
        format.json { render json:"Email not found", :status => 400 }
      end
    end
  end

  def reset_password
    remember_token = params[:reset_password_token]
    @user = User.find_by_remember_token(remember_token)
    render :layout => false
  end
  

  def update_password
    remember_token = params[:reset_password_token]
    @user = User.find_by_remember_token(remember_token)
    if @user
      @user.password = params[:user][:password] 
      @user.password_confirmation = params[:user][:password_confirmation]
      if @user.save
        flash[:success] = "Password changed successfully"
        render :layout => false
      else
        render 'reset_password', :layout => false  
      end
    else
      render 'reset_password', :layout => false 
    end
  end
  
  def create
    @user = User.new(params[:user])
    @user.phone_number = params[:phone_number]
    if @user.save
      begin
        Resque.enqueue(SendUserActivationCodeResqueJob, @user.id, @user.phone_number)
      rescue
        logger.debug "failed to enqueue resque job"
      end
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
      update_result = user.update_attribute(:phone_number, phone_number)
      if (update_result)
        begin
          Resque.enqueue(SendUserActivationCodeResqueJob, user.id, phone_number)
        rescue
          logger.debug "failed to enqueue resque job"
        end
        respond_to do |format|
          format.json {render json:"ok"}
        end
      else
        respond_to do |format|
          format.json {render json:"failed to save phone number", :status => 400}
        end
      end
    else
      respond_to do |format|
        format.json {render json:"unauthorized user", :status => 401}
      end
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
      format.json { render json: @requested_friends, :include_fields => [:friendship_id] }
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
  
  def aliyun_oss_credentials
    key = params[:encryption_key]
    @encrypted_data = encrypted_aliyun_oss_credentials(key)
    respond_to do |format|
      format.json { render json: { :credentials => "nothing to see" } }
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
    redirect_to s3_avatar_url(@user).to_s
  end

  def activate
    user = User.find(params[:id])
    code = params[:confirmation_code].to_i
    if (user.updated_at < 1.hour.ago)
      user.update_attribute(:confirmation_code, Random.new.rand(100_000..999_999))
      begin
        Resque.enqueue(SendUserActivationCodeResqueJob, user.id, user.phone_number)
      rescue
        logger.debug "failed to enqueue resque job"
      end
      respond_to do |format|
        format.json { render json: {:error_message => "Your code has expired. We have sent you a new code."}, :status => 401 }
      end
      return
    end
    if (user.confirmation_code == 0 or user.confirmation_code == code.to_i)
      user.update_attribute(:confirmation_code, 0)
      respond_to do |format|
        format.json { render json: "ok" }
      end
    else   
      respond_to do |format|
        format.json { render json: {:error_message => "Invalid code"}, :status => 401 }
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
