class InformUserOfNewCommentResqueJob
  
  @queue = "comment_notification"

  def self.perform(comment_id, at_time, should_inform_owner)
    puts "beginning job"
    comment = Comment.find_by_id(comment_id)
    return unless comment
    post = comment.post
    commenter = comment.user
    post_owner = post.user
    at_time = comment.created_at
    puts "beginning posting notifications"
    #firstly post a notification to post owner
    if (commenter.id != post_owner.id and should_inform_owner)
      notification = post_owner.notifications.build( :content => "<n5><a href=\"memcap://users/#{commenter.id}\" >#{commenter.name}</a> commented on your <a href=\"memcap://posts/#{post.id}\">post</a> <a href=\"memcap://comments/#{comment.id}\"/></n5>", :viewed => false)
      if (notification.save)
        puts("successfully saved notification to post owner")
      else
        Resque.enqueue(self, comment_id, at_time, should_inform_owner)
      end #if not.save
    end #if commenter.id

    #send notifications to commenter
    notification = commenter.notifications.build( :content => "<n4>You commented on a <a href=\"memcap://posts/#{post.id}\">post</a> <a href=\"memcap://comments/#{comment.id}\"/></n4>", :viewed => false)
    notification.save
    
    puts "posting to user who commented before "
    puts at_time
    should_inform_owner = false;
    #then post all notifications who participate in a post discussion
    page = 1
    begin
      #query all users that commented on the post before this new comment is added
      comments_from_unique_users = Comment.on_post_by_unqiue_users(post,at_time).paginate(:page => page)
      comments_from_unique_users.each do |comment|
        #if (comment.user_id != post_owner.id)
          notification = Notification.new( :content => "<n><a href=\"memcap://users/#{commenter.id}\" >#{commenter.name}</a> commented on a <a href=\"memcap://posts/#{post.id}\">post</a> you commented on. <a href=\"memcap://comments/#{comment.id}\"/></n>", :viewed => false)
          notification.receiver_id = comment.user_id
          if (notification.save)
            at_time = comment.created_at
          else
            Resque.enqueue(self, comment_id, at_time, should_inform_owner)
          end #if not.save
        #end # if id is different
      end #comments_from_unqiue_users.each do
    end while comments_from_unique_users.any? #begin
    puts "job ended sucessfully"
  rescue Resque::TermException
    Resque.enqueue(self, comment_id, at_time, should_inform_owner)
  end #def/rescue

end
