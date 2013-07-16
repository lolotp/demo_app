class FollowsController < ApplicationController
  before_filter :check_for_mobile, :only => [:create, :destroy]
  before_filter :signed_in_user
  before_filter :correct_user, :only => [:destroy]

	def create
    @user = User.find(params[:follow][:followee_id])
    current_user.follow!(@user)
    followship = current_user.following?(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
      if (followship)
        format.json { render json: {:status => "ok", :id => followship.id } }
      else
        format.json { render json: {:status => "failed", :id => followship } }
      end
    end
	end

	def destroy
		f = Follow.find(params[:id])
		#@user = f.followee
		#current_	user.unfollow!(@user)
		#followship = current_user.following?(@user)
		respond_to do |format|
      #format.html { redirect_to @user }
      format.js
      if (f.destroy)
        format.json { render json: {:status => "ok", :id => f.id } }
      else
        format.json { render json: {:status => "failed", :id => f } }
      end
    end
	end

  private 
    def correct_user
      @followship = current_user.follows.find_by_id(params[:id])
      unauthorized_result if @followship.nil?
    end
end
