class ConciergeAppsController < ApplicationController
  before_filter :check_for_mobile, :only => [:index]
  before_filter :signed_in_user
  before_filter :admin_user, :only => [:new, :edit, :update, :create, :destroy]

  def index
    if params[:iso_country_code]
      @concierge_apps = ConciergeApp.where(:iso_country_code => params[:iso_country_code])
      if @concierge_apps.empty?
        @concierge_apps = ConciergeApp.where(:iso_country_code => "global")
      end
    else
      @concierge_apps = ConciergeApp.where("")
    end
    @concierge_apps = @concierge_apps.order(:iso_country_code)
    respond_to do |format|
      if params[:iso_country_code]
        format.json { render json: @concierge_apps, :iso_country_code => params[:iso_country_code] }
      else
        format.json { render json: @concierge_apps }
      end
      format.html {}
    end
  end

  def edit
    @concierge_app = ConciergeApp.find(params[:id])
  end

  def destroy
    @concierge_app = ConciergeApp.find(params[:id])
    @concierge_app.destroy
    redirect_to concierge_apps_path
  end

  def new
    @concierge_app = ConciergeApp.new
  end
  
  def create
    @concierge_app = ConciergeApp.new(params[:concierge_app])
    if @concierge_app.save
      redirect_to concierge_apps_path
    else
      redirect_to new_concierge_apps_path
    end
  end

  def update
    @concierge_app = ConciergeApp.find(params[:id])
    if @concierge_app.update_attributes(params[:concierge_app])  
      redirect_to concierge_apps_path
    else
      redirect_to edit_concierge_apps_path(@concierge_app)
    end
  end
 
end
