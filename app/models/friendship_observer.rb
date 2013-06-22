class FriendshipObserver < ActiveRecord::Observer
  observe :friendship
  
  def after_create(friendship)
    receiver = friendship.friend
    adder = friendship.user
    notification = receiver.notifications.build( :content => "#{adder.name} added you as friend", :viewed => false, :type => "friend request")
    notification.save
  end
end
