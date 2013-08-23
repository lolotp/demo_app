class PublicPostLocation < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :release

  belongs_to :post
  validates :post_id, :presence => true, :uniqueness => true
end
