class NotificationsController < ApplicationController
  before_filter :check_for_mobile
  before_filter :signed_in_user 
  before_filter :correct_user,  only: :update

  def update
    @notification = current_user.notifications.find_by_id(params[:id])
    @notification.viewed = true
    respond_to do |format|
      format.html {}
      if @notification.save
        format.json { render json: "ok" }
      else
        format.json { render json: @notification.errors.full_messages, :status => 400 }
      end
    end
  end
  
  private 
    def correct_user
      @notification = current_user.notifications.find_by_id(params[:id])
      unauthorized_result if @notification.nil?
    end
end
