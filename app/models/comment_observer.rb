class CommentObserver < ActiveRecord::Observer
  observe :comment
  
  def after_create(comment)
    post = comment.post
    commenter = comment.user
    post_owner = post.user
    if (commenter.id != post_owner.id)
      notification = post_owner.notifications.build( :content => "<href=\"memcap://users/#{commenter.id}\" >#{commenter.name}</ref> commented on your <ref=\"memcap://posts/#{post.id}\">post</ref> <ref=\"memcap://comments/#{comment.id}\"/>", :viewed => false)
      notification.save
    end
  end
end
