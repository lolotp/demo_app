class Post < ActiveRecord::Base
  attr_accessible :content, :file_url, :latitude, :longitude, :rating, :privacy_option, :subject, :thumbnail_url, :release
  belongs_to :user
  belongs_to :landmark

  has_many :comments, dependent: :destroy

  validates :file_url, presence: true
  validates :thumbnail_url, presence: true
  validates :content, presence: true
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
    where("(user_id IN (#{friend_user_ids}) AND (privacy_option <> 'private') AND ( (release IS NULL) OR (release > now())) ) OR (user_id = :user_id) ", 
          user_id: user.id)
  end

  def self.from_followees(user)
    followee_user_ids = "SELECT followee_id FROM follows
                         WHERE user_id = :user_id"
    where("(user_id IN (#{followee_user_ids}) AND privacy_option = 'public' AND ( (release IS NULL) OR (release > now())) ) OR (user_id = :user_id) ", 
          user_id: user.id)
  end
  # { :levels => [ { :dist => 2000, :popularity => 0 }, {:dist => 10000, :popularity => 100 } ] }
  def self.from_friends_by_social_radius(user, cur_lat, cur_long, levels)
    friend_user_ids = "SELECT friend_id FROM friendships
                         WHERE user_id = :user_id AND status='accepted'"   
    radius_filter = ""
    levels.each do |level|
      dist = level[:dist]
      popularity = level[:popularity]
      level_filter = "(earth_box(ll_to_earth(#{cur_lat},#{cur_long}), #{dist}) @> ll_to_earth(latitude, longitude) AND view_count+like_count > #{popularity})"
      if (radius_filter != "") 
        radius_filter += " OR "
      end
      radius_filter += level_filter
    end
    where("(#{radius_filter}) AND ( (user_id IN (#{friend_user_ids}) AND privacy_option <> 'private' AND ( (release IS NULL) OR (release > now())) ) OR (user_id = :user_id) OR (privacy_option = 'public' AND ( (release IS NULL) OR (release > now()))) )", 
          user_id: user.id)
  end

  def as_json(options={})
      json_obj = super
      json_obj[:author_name] = self.user.name
      json_obj[:author_email] = self.user.email
      json_obj
  end
end
