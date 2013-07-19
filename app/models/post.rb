include PostsHelper

class Post < ActiveRecord::Base

  attr_accessible :content, :file_url, :latitude, :longitude, :rating, :privacy_option, :subject, :thumbnail_url, :release
  belongs_to :user
  belongs_to :landmark

  has_many :comments, dependent: :destroy

  validates :file_url, presence: true
  validates :thumbnail_url, presence: true
  validates :user, presence: true
  validates :privacy_option, presence: true
  
  default_scope order: 'posts.created_at DESC'
  
  def self.from_friends_by_location(user, cur_lat, cur_long)
    friend_user_ids = "SELECT friend_id FROM friendships
                         WHERE user_id = :user_id"
    max_dist = 50000;
    distance_filter = "earth_box(ll_to_earth(#{cur_lat},#{cur_long}), #{max_dist}) @> ll_to_earth(latitude, longitude)"                         
    where("(user_id IN (#{friend_user_ids}) OR user_id = :user_id) AND (#{distance_filter})", 
          user_id: user.id)
  end
  
  def self.from_friends(user)
    friend_user_ids = "SELECT friend_id FROM friendships
                         WHERE user_id = :user_id AND status='accepted'"                
    where("(user_id IN (#{friend_user_ids}) AND (privacy_option <> 'private') )", 
          user_id: user.id)
  end

  def self.from_followees(user)
    followee_user_ids = "SELECT followee_id FROM follows
                         WHERE user_id = :user_id"
    where("(user_id IN (#{followee_user_ids}) AND privacy_option = 'public')", 
          user_id: user.id)
  end
  # { :levels => [ { :dist => 2000, :popularity => 0 }, {:dist => 10000, :popularity => 100 } ] }
  def self.from_friends_by_social_radius(user, cur_lat, cur_long, levels)
    friend_user_ids = "SELECT friend_id FROM friendships
                         WHERE user_id = :user_id AND status='accepted'"
    radius_filter = gen_radius_filter_query(cur_lat, cur_long, levels)
    where("(#{radius_filter}) AND ( (user_id IN (#{friend_user_ids}) AND privacy_option <> 'private') OR (user_id = :user_id) OR (privacy_option = 'public' AND ( (release IS NULL) OR (release < now())) ) )", 
          user_id: user.id)
  end

  def self.number_of_unreleased_capsule_by_location(user, cur_lat, cur_long, levels)
    radius_filter = gen_radius_filter_query(cur_lat, cur_long, levels)
    friend_user_ids = "SELECT friend_id FROM friendships
                         WHERE user_id = " + user.id.to_s() + " AND status='accepted'"
    where(" ( (privacy_option = 'public') AND (release IS NOT NULL AND release > now()) AND (user_id NOT IN (#{friend_user_ids}) ) ) AND #{radius_filter}").count
  end

  def self.number_of_unreleased_capsule_by_followees(user)
    followee_user_ids = "SELECT followee_id FROM follows
                         WHERE user_id = " + user.id.to_s()
    where(" ( (privacy_option = 'public') AND (release IS NOT NULL AND release > now()) AND (user_id IN (#{followee_user_ids}) ) )").count
  end

  def as_json(options={})
    json_obj = super
    if (self.release and self.release > DateTime.now)
      json_obj[:subject]  = "Unreleased capsule"
      json_obj[:content]  = "Release on " + self.release.to_s()
      json_obj[:file_url] = "TimeCapsule"
      json_obj[:thumbnail_url] = "TimeCapsule"
    end
    json_obj[:author_name] = self.user.name
    json_obj[:author_email] = self.user.email
    json_obj
  end
end
