class SessionsController < ApplicationController
  before_filter :check_for_mobile, :only => [:create]
  
  def new
  end
  
  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if not user
      respond_to do |format|
        format.json {render json: "You haven't registered for an account with this email, would you like to register for one ?", :status => 404 }
        flash.now[:error] = 'Unknown account'
        format.html {render 'new'}
      end
      return
    end
    if user.authenticate(params[:session][:password])
      if (user.confirmation_code != 0)
        flash[:error] = "Unactivated account"
        respond_to do |format|
          format.json { render json:  { :unactivated_warning => "Unactivated account", :user_id => user.id } }
          format.html { redirect_to root_path }
        end
      else
        sign_in user
        lat = params[:latitude]
        long = params[:longitude]
        if mobile_device?
          redirect_back_or(root_path, lat, long)
        else
          redirect_back_or(post_reports_path, lat, long)
        end
      end
    else      
      respond_to do |format|
        format.json {render json: "Password entered does not match registered email.", :status => 401}
        flash.now[:error] = 'Invalid email/password combination'
        format.html {render 'new'}
      end     
    end

  end
  
  def destroy
    sign_out
    redirect_to root_url
  end
end
