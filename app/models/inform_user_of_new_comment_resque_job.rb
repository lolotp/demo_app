class InformUserOfNewCommentResqueJob
  def perform(comment, at_time)
    post = comment.post
    commenter = comment.user
    post_owner = post.user
    
    #firstly post a notification to post owner
    if (commenter.id != post_owner.id)
      notification = post_owner.notifications.build( :content => "<n><a href=\"memcap://users/#{commenter.id}\" >#{commenter.name}</a> commented on your <a href=\"memcap://posts/#{post.id}\">post</a> <a href=\"memcap://comments/#{comment.id}\"/></n>", :viewed => false)
      notification.save #do not process save failure, assume that failure to save notification is rare and it is ok for user to sometimes missthe notification
    end
    
    #then post all notifications who participate in a post discussion
    page = 1
    begin
      #query all users that commented on the post before this new comment is added
      users = User.where("exists created_at < :at_time", :at_time => at_time).paginate(:page => page)
      users.each do |user|
        notification = user_owner.notifications.build( :content => "<n><a href=\"memcap://users/#{commenter.id}\" >#{commenter.name}</a> commented on a <a href=\"memcap://posts/#{post.id}\">post</a> you commented on. <a href=\"memcap://comments/#{comment.id}\"/></n>", :viewed => false)
        
        if (notification.save)
          at_time = comment.created_at
        end#do not process save failure, assume that failure to save notification is rare and it is ok for user to sometimes miss the notification
      end
      page = page + 1
      #increase page to pull the next set of comments
    end while comments.any?
  rescue Resque::TermException
    Resque.enqueue(self, comment, at_time)
  end

  def on_failure_retry(e, *args)
    Resque.enqueue self, *args
  end
end
