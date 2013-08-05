class PublicPostLocation < ActiveRecord::Base
  attr_accessible :latitude, :longitude

  belongs_to :post
  validates :post_id, :presence => true, :uniqueness => true
end
