class EventsController < ApplicationController
  after_filter :set_access_control_headers

  def new
  end

  def index
    @events = Event.all
    respond_to do |format|
      format.html { render json: @events } 
      format.json { render json: @events }   
    end
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

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    respond_to do |format|
      format.html { render json: @event }
      format.json { render json: @event }
    end  
  end

  def set_access_control_headers
    #headers['Access-Control-Allow-Origin'] = '*'
    #headers['Access-Control-Request-Method']= '*'
  end
end
