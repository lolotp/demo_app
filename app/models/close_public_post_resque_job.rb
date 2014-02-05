require 'resque-retry'

class ClosePublicPostResqueJob
  extend Resque::Plugins::Retry unless Rails.env.test?
  @queue = "time_capsule_notification"
  
  @retry_limit = 3
  def self.perform(post_id)
    puts "started job closing public post " + post_id.to_s
    post = Post.find(post_id)
    post.update_attribute(:privacy_option, 'personal')
  end

end
