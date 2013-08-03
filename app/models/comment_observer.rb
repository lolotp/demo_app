class CommentObserver < ActiveRecord::Observer
  observe :comment
  
  def after_create(comment)
    Resque.enqueue(InformUserOfNewCommentResqueJob, comment.id, comment.created_at, true)
    #post = comment.post
    #commenter = comment.user
    #post_owner = post.user
    #if (commenter.id != post_owner.id)
      #notification = post_owner.notifications.build( :content => "<n><a href=\"memcap://users/#{commenter.id}\" >#{commenter.name}</a> commented on your <a href=\"memcap://posts/#{post.id}\">post</a> <a href=\"memcap://comments/#{comment.id}\"/></n>", :viewed => false)
      #notification.save
    #end
  end
end
