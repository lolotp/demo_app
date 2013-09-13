class ConciergeAppsController < ApplicationController
  before_filter :check_for_mobile, :only => [:index]
  before_filter :signed_in_user

  def index
    if params[:iso_country_code]
      @concierge_apps = ConciergeApp.where(:iso_country_code => params[:iso_country_code])
      if @concierge_apps.empty?
        @concierge_apps = ConciergeApp.where(:iso_country_code => "global")
      end
    else
      @concierge_apps = ConciergeApp.all
    end
    respond_to do |format|
      format.json { render json: @concierge_apps}
    end
  end 
end
