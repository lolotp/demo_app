class LandmarksController < ApplicationController
  before_filter :check_for_mobile, only: :index
  before_filter :signed_in_user, only: :index
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

  def index
    lat = params[:latitude]
    long = params[:longitude]
    levels = params[:levels]
    if (lat and long and levels)
      @landmarks = Landmark.feed_by_social_radius(lat,long,levels).paginate(page: params[:page])
    else
      @landmarks = Landmark.where("").paginate(page: params[:page])
    end
    respond_to do |format|
      format.html {}
      format.json { render json: @landmarks }
    end
  end

  private
    def admin_user
      unauthorized_result unless current_user.admin?
    end
end
