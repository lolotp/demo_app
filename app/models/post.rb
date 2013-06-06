class Post < ActiveRecord::Base
  attr_accessible :content, :file_url, :latitude, :longitude, :rating, :privacy_option
  belongs_to :user

  has_many :comments, dendent: :destroy

  validates :content, presence: true
  validates :user, presence: true
  validates :privacy_option, presence: true
  
  default_scope order: 'posts.created_at DESC'
  
  def self.from_friends_by_location(user, cur_lat, cur_long)
    friend_user_ids = "SELECT friend_id FROM friendships
                         WHERE user_id = :user_id"
    max_dist = 50000;
    distance_filter = "earth_box(ll_to_earth(#{cur_lat},#{cur_long}), #{max_dist}) @> ll_to_earth(latitude, longitude)"                         
    where("user_id IN (#{friend_user_ids}) OR user_id = :user_id AND (#{distance_filter})", 
          user_id: user.id)
  end
  
  def self.from_friends(user)
    friend_user_ids = "SELECT friend_id FROM friendships
                         WHERE user_id = :user_id"                
    where("user_id IN (#{friend_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end
  
  def self.from_friends_by_social_radius(user, cur_lat, cur_long, levels)
    friend_user_ids = "SELECT friend_id FROM friendships
                         WHERE user_id = :user_id"   
    radius_filter = ""
    levels.each do |level|
      dist = level[:dist]
      popularity = level[:popularity]
      level_filter = "earth_box(ll_to_earth(#{cur_lat},#{cur_long}), #{dist}) @> ll_to_earth(latitude, longitude) AND view_count+like_count > #{popularity}"
      radius_filter += level_filter
    end
    where("user_id IN (#{friend_user_ids}) OR user_id = :user_id AND (#{radius_filter})", 
          user_id: user.id)
  end

  def as_json(options={})
      json_obj = super
      json_obj[:author_name] = self.user.name
      json_obj[:author_avatar] = self.user.gravatar_url
      json_obj
  end
end
