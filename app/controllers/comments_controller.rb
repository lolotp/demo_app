class CommentsController < ApplicationController
  before_filter :check_for_mobile, :only => [:create]
  before_filter :signed_in_user

  def create
    respond_to do |format|
      @comment = current_user.comments.build(params[:comment])
      @comment.post_id = params[:post_id]
      if (@comment.save)
        format.json { render json: { :id => @comment.id } }
      else
        format.json { render json:@comment.errors.full_messages.first, :status => 400 }
      end
    end
  end
end
