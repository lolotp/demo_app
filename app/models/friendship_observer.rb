class FriendshipObserver < ActiveRecord::Observer
  observe :friendship
  
  def after_create(friendship)
    receiver = friendship.friend
    adder = friendship.user
    notification = receiver.notifications.build( :content => "<a href=\"memcap://users/#{adder.id}\" >#{adder.name}</a> added you as friend", :viewed => false)
    notification.save
  end
end
