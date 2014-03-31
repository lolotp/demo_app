class FriendshipObserver < ActiveRecord::Observer
  observe :friendship
  
  def after_create(friendship)
    receiver = friendship.friend
    adder = friendship.user
    puts "after creating friendship" 
    puts friendship.status
    if friendship.status == "pending"
      notification = receiver.notifications.build( :content => "<n2><a href=\"memcap://users/#{adder.id}\" >#{adder.name}</a> added you as friend</n2>", :viewed => false)
      notification.save

      uri = URI.parse(ENV['PUSH_URL'])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      message = "#{adder.name} sent you a friend request"
      message_url = "memcap://users/#{adder.id}"
      data = { :appid => ENV["PUSH_APPID"], :username => ENV["PUSH_USERNAME"], :password => ENV["PUSH_PASSWORD"], :message => message, :messageurl => message_url, :id_fordevice => receiver.email }
      request = Net::HTTP::Post.new(uri.path, {})
      request.body = data.to_query
      response = http.request(request)
    end
  end
end
