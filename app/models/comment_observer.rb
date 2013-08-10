#this observer enqueue a job to send notifications to users who are involved in a post discussion every time a new comment is posted
class CommentObserver < ActiveRecord::Observer
  observe :comment
  
  def after_create(comment)
    Resque.enqueue(InformUserOfNewCommentResqueJob, comment.id, comment.created_at, true)
  end
end
