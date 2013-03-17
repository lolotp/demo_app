class UsersController < ApplicationController
  def new
  end
  
  def show
    @user = User.find(params[:id])
  end

  def get_posts
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
      if (signed_in?)
        format.html { render :text => ret_str }
      else
        format.html { render :text => "Unauthorized", :status => 401 }
      end
    end
  end
end
