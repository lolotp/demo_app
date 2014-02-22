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
    @talk = @event.talks.find(params[:id])
    respond_to do |format|
      format.html { render json: @talk }
      format.json { render json: @talk }
    end
  end

  def topics
    topics = params[:topics]
    query_string = ""
    topics.each do |topic|
      to_add = "topics like '%\"#{topic}\"%'"
      if query_string == ''
        query_string = to_add
      else
        query_string += "and " + to_add
      end
    end
    @talks = Talk.where("#{query_string}") 
    respond_to do |format|
      format.html { render json: @talks }
      format.json { render json: @talks }
    end
  end

  def destroy
    @event = Event.find(params[:event_id])
    @talk = @event.talks.find(params[:id])
    @talk.destroy
    respond_to do |format|
      format.html { render json: @talk }
      format.json { render json: @talk }
    end  
  end
end
