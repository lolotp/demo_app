class SessionsController < ApplicationController
  before_filter :check_for_mobile, :only => [:create]
  
  def new
  end
  
  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user      
    else      
      if mobile_device?
        respond_to do |format|
          format.json {render json: "Unable to authenticate user", :status => 404}
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
