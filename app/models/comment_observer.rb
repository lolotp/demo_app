class CommentObserver < ActiveRecord::Observer
  observe :comment
  
  def after_create(comment)
    post = comment.post
    commenter = comment.user
    post_owner = post.user
    if (commenter.id != post_owner.id)
      notification = post_owner.notifications.build( :content => "<a href=\"memcap://users/#{commenter.id}\" >#{commenter.name}</a> commented on your <a href=\"memcap://posts/#{post.id}\">post</a> <a href=\"memcap://comments/#{comment.id}\"/>", :viewed => false)
      notification.save
    end
  end
end
