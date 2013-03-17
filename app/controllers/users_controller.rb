class UsersController < ApplicationController
  def new
  end
  
  def show
    @user = User.find(params[:id])
  end

  def get_posts
    respond_to do |format|
      if (signed_in?)
        format.html { render :json => current_user.microposts }
      else
        format.html { render :text => "Unauthorized", :status => 401 }
      end
    end
  end
end
