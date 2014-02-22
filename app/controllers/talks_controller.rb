class TalksController < ApplicationController
  def new
    @event = Event.find(params[:event_id])
  end


  def create
    @event = Event.find(params[:event_id])
    @talk = @event.talks.build(params[:talk])
    if @event.save
      respond_to do |format|
        #format.html { redirect_to @talk }
        format.html { render json: @talk }
        format.json { render json: @talk }
      end 
    end
  end

  def show
    @event = Event.find(params[:event_id])
    @talk = @event.talks.find(params[:talk_id])
    respond_to do |format|
      format.html { render json: @talk }
      format.json { render json: @talk }
    end
  end
end
