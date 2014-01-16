require 'resque-retry'

class SendTimeCapsuleToUserResqueJob
  extend Resque::Plugins::Retry unless Rails.env.test?
  @queue = "time_capsule_notification"
  
  @retry_limit = 3
  def self.perform(from_user_id, to_user_id, post_id)
    puts "started job sending notification from user id " + from_user_id.to_s + " to user id " + to_user_id.to_s
    to_user = User.find(to_user_id)
    from_user = User.find(from_user_id)
    
    #check if sender is friend of receiver
    if from_user.friend?(to_user)
      post = Post.find(post_id)

      notification = to_user.notifications.build( :content => "<n3><a href=\"memcap://users/#{from_user.id}\" >#{from_user.name}</a> sent you a <a href=\"memcap://posts/#{post.id}\">time capsule</a>", :viewed => false)
      if (notification.save)
          puts("successfully saved notification to post owner")
      else
        raise "failure can't send notification"
      end
    end
  end

end
