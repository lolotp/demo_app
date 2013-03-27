class Post < ActiveRecord::Base
  attr_accessible :content, :file_url, :latitude, :longitude, :rating
  belongs_to :user

  validates :content, presence: true
  validates :user, presence: true
  
  default_scope order: 'posts.created_at DESC'
end
