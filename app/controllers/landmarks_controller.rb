class LandmarksController < ApplicationController
  before_filter :admin_user, only: :create

  def create
    @landmark = params[:landmark]
    @landmark.save
    respond_to do |format|
      format.html { }
      if (@landmark)
        format.json { render json: @landmark }
      else
        format.json { render json: @landmark.errors.full_messages, :status => 400 }
      end
    end
  end

  def show
    @landmark = Landmark.find_by_id(params[:id])
    @posts = @landmark.posts
    respond_to do
      format.html { }
      format.json { render json: { :post_list => @posts, :landmark => @landmark } }
    end
  end

  private
    def admin_user
      unauthorized_result unless current_user.admin?
    end
end
