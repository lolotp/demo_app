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
      format.json { render json: {:follow => followship } }
    end
	end

	def destroy
		Follow.find(params[:id]).destroy
		#@user = f.followee
		#current_	user.unfollow!(@user)
		#followship = current_user.following?(@user)
		respond_to do |format|
      #format.html { redirect_to @user }
      format.js
      format.json { render json: {:follow => nil } }
    end
	end

  private 
    def correct_user
      @followship = current_user.follows.find_by_id(params[:id])
      unauthorized_result if @followship.nil?
    end
end
