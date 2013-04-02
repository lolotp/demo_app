class Post < ActiveRecord::Base
  attr_accessible :content, :file_url, :latitude, :longitude, :rating, :privacy_option
  belongs_to :user

  validates :content, presence: true
  validates :user, presence: true
  validates :privacy_option, presence: true
  
  default_scope order: 'posts.created_at DESC'
  
  def self.from_friends(user)
    friend_user_ids = "SELECT friend_id FROM friendships
                         WHERE user_id = :user_id"
    where("user_id IN (#{friend_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end
end
