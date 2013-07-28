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

  def create
    send_at = params[:send_at]
    @receiver = User.find(params[:receiver_id])
    if (send_at)
      Delayed::Job.enqueue(SendNotificationJob.new(params[:content], @receiver), :run_at => send_at)
      respond_to do |format|
        format.json { render json: "ok" }
      end
    else
      @notification = Notification.create(params[:notification])
      @notification.receiver_id = @receiver.id
      respond_to do |format|
        if (@notification.save)
          format.json { render json: @notification }
        else
          format.json { render json: { :errors => notification.errors }, :status => 400 } 
        end
      end
    end
  end
  
  private 
    def correct_user
      @notification = current_user.notifications.find_by_id(params[:id])
      unauthorized_result if @notification.nil?
    end
end
