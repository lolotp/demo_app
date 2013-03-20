class MicropostsController < ApplicationController
  def new
    mobile_flag = params[:is_mobile]
    if (mobile_flag and mobile_flag == "1")
      new_mobile  
  end
  
  def new_mobile
    respond_to do |format|
      if (signed_in?)
        p = current_user.microposts.new
        p.content = params[:content]
        if p.save
          format.html { render :text => "Ok" }
        else
          format.html { render :text => "Internal server error", :status => 500 }
        end
      else
        format.html { render :text => "Unauthorized", :status => 401 }
      end
    end
  end
end
