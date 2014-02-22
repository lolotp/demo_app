class EventsController < ApplicationController

  def new
  end

  def create
    @event = Event.new(params[:event])
    if @event.save
      respond_to do |format|
        format.json { render json: @event }
        format.html { render json: @event }#redirect_to @event }
      end 
    end
  end

  def show
    @event = Event.find(params[:id])
    @talks = @event.talks
    respond_to do |format|
      format.html { render json: @talks }
      format.json { render json: @talks }
    end
  end
end
