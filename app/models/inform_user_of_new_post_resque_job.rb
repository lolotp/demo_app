require 'resque-retry'

class InformUserOfNewPostResqueJob
  extend Resque::Plugins::Retry unless Rails.env.test?
  
  def self.perform(post_id)
    post = Post.find(post_id)
    user = post.user
    user.friends.each do |f|
      uri = URI.parse(ENV['PUSH_URL'])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      message = "#{user.name} just posted a new picture/video"
      message_url = "memcap://posts/#{post.id}"
      data = { :appid => ENV["PUSH_APPID"], :username => ENV["PUSH_USERNAME"], :password => ENV["PUSH_PASSWORD"], :message => message, :messageurl => message_url, :id_fordevice => f.email }
      request = Net::HTTP::Post.new(uri.path, {})
      request.body = data.to_query
      response = http.request(request)    
    end
  end
end
