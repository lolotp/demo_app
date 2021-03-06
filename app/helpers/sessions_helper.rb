module SessionsHelper
  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    self.current_user = user
  end
  
  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end
  
  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end
  
  def redirect_back_or(default, lat, long)
    redirect_path = session[:return_to] || url_for(default)
    redirect_to (redirect_path.to_s + "?" + {:latitude => lat, :longitude => long}.to_query)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

  def unauthorized_result
    if (mobile_device?) 
      respond_to do |format|
        format.html {render :text => "Unauthorized"}
        format.json { render :text => "Unauthorized", :status => 401 }
      end
    else        
      store_location
      redirect_to signin_url, notice: "Please sign in." 
    end
  end  

  def signed_in_user
    unless signed_in?
      unauthorized_result
    end
  end

  def admin_user
    unauthorized_result unless current_user.admin?
  end
end
