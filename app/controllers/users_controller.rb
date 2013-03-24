class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def show
    mobile_flag = params[:is_mobile]
    if (mobile_flag and mobile_flag == "1")
      show_mobile
    else
      if (signed_in? and current_user[:id] == params[:id])
        @user = User.find(params[:id])
        #@user = current_user
      else
        flash[:signin_first] = "Please sign in first"
        redirect_to signin_path
      end
    end
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      # Handle a successful save.
    else
      render 'new'
    end
  end
  
  def show_mobile
    respond_to do |format|
      if (signed_in?)
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
      else
        format.html { render :text => "Unauthorized", :status => 401 }
      end
    end
  end
end
