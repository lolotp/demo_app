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
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password

  has_many :microposts, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, :through => :friendships, :source => :friend, :conditions => "status = 'accepted'"
  has_many :pending_friends, :through => :friendships, :source => :friend, :conditions => "status ='pending'"
  has_many :requested_friends, :through => :friendships, :source => :friend, :conditions => "status = 'requested'"

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
  
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  
  def feed
    Post.from_friends(self)
  end
  
  def feed_by_location(cur_lat, cur_long)
    Post.from_friends_by_location(self, cur_lat, cur_long)
  end
  
  def feed_by_social_radius(cur_lat, cur_long, levels)
    Post.from_friends_by_social_radius(self, cur_lat, cur_long, levels)
  end

  def friend?(other_user)
    f = friendships.find_by_friend_id(other_user.id)
    f and f.status == "accepted"
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
  
  def self.find_matched_users(search_string)    
    where("name LIKE '%#{search_string}%' OR email LIKE '%#{search_string}%'")
  end

private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
