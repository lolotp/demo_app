class Post < ActiveRecord::Base
  attr_accessible :content, :file_url, :latitude, :like_count, :longitude, :rating, :user_id, :view_count
  belongs_to :user

  validates :content, presence: true, length: { maximum: 140 }
  validates :user, presence: true
end
