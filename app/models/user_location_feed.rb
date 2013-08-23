class UserLocationFeed < ActiveRecord::Base
  attr_accessible :latitude, :longitude
  belongs_to :user
  belongs_to :post
end