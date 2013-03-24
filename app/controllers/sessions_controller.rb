class SessionsController < ApplicationController

  def new
  end
  
  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      if (is_mobile?)
        respond_to do |format|
          s = (user[:name] ? user[:name] : user[:email]) + "#" + user[:id].to_s
          format.html { render:text => s }
        end
      else 
        redirect_back_or user
      end
    else
      if (is_mobile?)
        respond_to do |format|
          format.html { render:text => "Unauthorized", :status => 401 }
        end
      else
        flash.now[:error] = 'Invalid email/password combination'
        render 'new'
      end
    end

  end
  
  def destroy
    sign_out
    redirect_to root_url
  end
end
