require 'resque-retry'

INF = 1000000000

class InformUserOfNewPostResqueJob
  extend Resque::Plugins::Retry unless Rails.env.test?

  @queue = "content_notification"

  def self.send_notification (from_user, to_user, post)
    uri = URI.parse(ENV['PUSH_URL'])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    message = "#{from_user.name} just posted a new picture/video"
    message_url = "memcap://posts/#{post.id}"
    data = { :appid => ENV["PUSH_APPID"], :username => ENV["PUSH_USERNAME"], :password => ENV["PUSH_PASSWORD"], :message => message, :messageurl => message_url, :id_fordevice => to_user.email }
    request = Net::HTTP::Post.new(uri.path, {})
    request.body = data.to_query
    response = http.request(request)
  end  

  def self.perform(post_id)
    post = Post.find(post_id)
    user = post.user

    friend_list_ids = []
    if post.privacy_option != 'personal'
      limit = REDIS_WORKER.get('FRIEND_COUNT_SEND_NOTIFICATION_LIMIT')
      limit = limit == nil ? INF : limit.to_i()
      if user.friends.count <= limit
        user.friends.each do |f|
            self.send_notification(user, f, post)
          friend_list_ids += [f.id]
        end
      end
    end

    if post.privacy_option == 'public'
      limit = REDIS_WORKER.get('FOLLOW_COUNT_SEND_NOTIFICATION_LIMIT')
      limit = limit == nil ? INF : limit.to_i()
      if user.followers.count <= limit
        user.followers.each do |follower|
          if not (friend_list_ids.include? follower.id)        
            self.send_notification(user, follower, post)
          end
        end
      end
    end
  end
end
