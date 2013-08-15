class CommentObserver < ActiveRecord::Observer
  observe :comment
  
  def after_create(comment)
    Resque.enqueue(InformUserOfNewCommentResqueJob, comment.id, comment.created_at, true)
  end
end
