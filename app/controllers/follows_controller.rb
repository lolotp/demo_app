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
		f = current_user.follows.find_by_id(params[:id])
    @user = f.followee
    f.destroy
		follow = current_user.follows.find_by_id(params[:id])
		respond_to do |format|
      format.html { redirect_to @user }
      format.js
      format.json { render json: {:follow => follow } }
    end
	end

  private 
    def correct_user
      @follow = current_user.follows.find_by_id(params[:id])
      unauthorized_result if @follow.nil?
    end
end
