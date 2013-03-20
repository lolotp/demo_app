class SessionsController < ApplicationController

  def new
  end
  
  def create
    user = User.find_by_email(params[:session][:email].downcase)
    mobile_flag = params[:is_mobile]
    if user && user.authenticate(params[:session][:password])
      if (mobile_flag and mobile_flag == "1")
        sign_in user
        respond_to do |format|
            if user[:name]
              format.html { render:text => user[:name] }
            else
              format.html { render:text => user[:email] } 
            end
        end
      else 
        sign_in user
        redirect_to user
      end
    else
      if (mobile_flag and mobile_flag == "1")
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
