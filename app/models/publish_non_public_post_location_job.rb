require 'resque-retry'

class PublishNonPublicPostLocationJob < Resque::JobWithStatus
  extend Resque::Plugins::Retry unless Rails.env.test?

  @queue = :publish_location_jobs
  @retry_limit = 10
  
  def self.save_to_user_feed(post, user_id)
    user_location_feed = UserLocationFeed.new(:latitude => post.latitude, :longitude => post.longitude, :release => post.release)
    user_location_feed.post_id = post.id
    user_location_feed.user_id = user_id
    if not user_location_feed.save
      duplicate_feed = UserLocationFeed.find_by_post_id(post.id)
      if not duplicated_feed
        raise "save failure"
      end
    end
  end
  
  def self.perform(post_id)
    post = Post.find_by_id(post_id)
    if post
      #publish to feed of post owner
      self.save_to_user_feed(post, post.user_id)
      
      if post.privacy_option != 'personal'
        #TODO paste to all friend feed here
        page = 1
        user = User.find(post.user_id)
        begin
          #query all users are friends with this user
          friends = user.friends.paginate(:page => page)
          friends.each do |friend|
            self.save_to_user_feed(post, friend.id)
          end #friends.each do
          page = page + 1  
        end while friends.any? #begin
      end #if privacy_option == 'friends'
    end #if post
  end
end
