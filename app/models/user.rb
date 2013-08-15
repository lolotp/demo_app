# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class User < ActiveRecord::Base
  include UsersHelper
  attr_accessible :email, :name, :password, :password_confirmation, :confirmation_code
  has_secure_password

  has_many :microposts, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :landmarks
  has_many :follows, dependent: :destroy
  has_many :followees, :through => :follows, :source => :followee
  has_many :reverse_follows, foreign_key: "followee_id", class_name: "Follow", dependent: :destroy
  has_many :followers, through: :reverse_follows, source: :user
  has_many :friendships, dependent: :destroy
  has_many :friends, :through => :friendships, :source => :friend, :conditions => "status = 'accepted'"
  has_many :pending_friends, :through => :friendships, :source => :friend, :conditions => "status ='pending'"
  has_many :requested_friends, :through => :friendships, :source => :friend, :conditions => "status = 'requested'"
  has_many :notifications, :foreign_key => :receiver_id, :dependent => :destroy
  has_many :unviewed_notifications, :class_name => 'Notification', :foreign_key => :receiver_id, :conditions => "viewed = false"
  has_many :post_reports
  has_many :post_bans

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
  before_create :create_confirmation_code
  
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  
  def post_feed
    Post.from_friends(self)
  end
  
  def post_feed_by_location(cur_lat, cur_long)
    Post.from_friends_by_location(self, cur_lat, cur_long)
  end
  
  def post_feed_by_social_radius(cur_lat, cur_long, levels)
    Post.from_friends_by_social_radius(self, cur_lat, cur_long, levels) 
  end

  def friend?(other_user)
    f = friendships.find_by_friend_id(other_user.id)
    f and f.status == "accepted"
  end

  def following?(other_user)
     f = follows.find_by_followee_id(other_user.id)
  end
  
  def pending_friend?(other_user)
    f = friendships.find_by_friend_id(other_user.id)
    f and f.status == "pending"
  end
  
  def requested_friend?(other_user)
    f = friendships.find_by_friend_id(other_user.id)
    f and f.status == "requested"
  end
  
  def request_friend!(other_user)
    unless id == other_user.id or Friendship.exists?({:user_id => id, :friend_id => other_user.id})
      pending_friendship = friendships.create(friend_id: other_user.id)
      pending_friendship.status = "pending"
      request_friendship = other_user.friendships.create(friend_id: id)
      request_friendship.status = "requested"
      transaction do
        pending_friendship.save
        request_friendship.save
      end
    end
  end
  
  def accept_friend!(other_user)
    pending_friendship = friendships.find_by_friend_id(other_user.id)
    request_friendship = other_user.friendships.find_by_friend_id(id)
    if pending_friendship and request_friendship
      pending_friendship.status = "accepted"
      request_friendship.status = "accepted"
      transaction do
        pending_friendship.save
        request_friendship.save
      end
    end
  end
  
  def unfriend!(other_user)
    my_friendship = friendships.find_by_friend_id(other_user.id)
    other_friendship = other_user.friendships.find_by_friend_id(id)
    if my_friendship.status == 'accepted'
      transaction do
        my_friendship.delete
        other_friendship.delete
      end
    end
  end
  
  def cancel_request!(other_user)
    my_friendship = friendships.find_by_friend_id(other_user.id)
    other_friendship = other_user.friendships.find_by_friend_id(id)
    if my_friendship.status == 'pending'
      transaction do
        my_friendship.delete
        other_friendship.delete
      end
    end
  end

  def decline_request!(other_user)
    my_friendship = friendships.find_by_friend_id(other_user.id)
    other_friendship = other_user.friendships.find_by_friend_id(id)
    if my_friendship.status == 'requested'
      transaction do
        my_friendship.delete
        other_friendship.delete
      end
    end
  end
  
  def self.find_matched_users(search_string)    
    where("name LIKE '%#{search_string}%' OR email LIKE '%#{search_string}%'")
  end

  def gravatar_url(options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(self.email.downcase)
    size = options[:size]
    return_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    return_url
  end

  def as_json(options={})
    json_obj = super(:only => [:name,:email,:id, :updated_at])
    if (self[:friendship_id])
      json_obj[:friendship_id] = self[:friendship_id]
    end
    json_obj
    #super(:only => [:name,:email,:id, :updated_at, :friendship_id])
  end

  def following?(other_user)
    follows.find_by_followee_id(other_user.id)
  end

  def follow!(other_user)
    follows.create!(followee_id: other_user.id)
  end

  def unfollow!(other_user)
    follows.find_by_followee_id(other_user.id).destroy
  end

  def post_follow_feed
    Post.from_followees(self)
  end

  def nonpassword_attributes
    [ :email, :name ]
  end

  def update_nonpassword_attributes(attributes)
    self.update_attribute(:email, attributes[:email])
    self.update_attribute(:name,  attributes[:name] )
  end
  
  def self.commented_on(post, before_time)
    select("DISTINCT ON (users.id) users.*, comments.created_at as at_time").joins("INNER JOIN comments ON users.id = comments.user_id").where("comments.post_id = :post_id AND comments.created_at < :before_time", :post_id => post.id, :before_time => before_time).order("users.id, at_time DESC")
  end

private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

    def create_confirmation_code
      self.confirmation_code = 0#Random.new.rand(100_000..999_999)
    end
end
