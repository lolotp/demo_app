class Dungeon < ActiveRecord::Base
  attr_accessible :description, :file_url, :latitude, :longitude, :rating
  belongs_to :user

  has_many :posts
  
end
