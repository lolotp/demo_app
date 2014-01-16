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
    end
  end
end
