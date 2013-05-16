class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :show, :edit, :update, :destroy, :friends]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user, only: :destroy
  before_filter :check_for_mobile, :only => [:create]

  def new
    @user = User.new
  end
  
  def show
    @user = User.find_by_id(params[:id])
    @posts = @user.posts.paginate(page: params[:page])
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user        
    else
      if mobile_device?
        respond_to do |format|
          format.json { render json: "Error registering user: " + @user.errors.full_messages.first, :status => 404 }
        end
      else
        render 'new'
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
    render 'show_friends'
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
  
  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
