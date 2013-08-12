class PostReportsController < ApplicationController
  before_filter :check_for_mobile, :only => [:create]
  before_filter :signed_in_user

  def create
    post_report = current_user.post_reports.build(params[:post_report])
    post_report.post_id = params[:post_id]
    respond_to do |format|
      if (post_report.save)
        format.json { render json:"ok" }
      else
        format.json { render json: post_report.errors.full_messages.first, :status => 400 }
      end
    end
  end

end
