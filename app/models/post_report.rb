class PostReport < ActiveRecord::Base
  attr_accessible :reason, :category
  belongs_to :user
  belongs_to :post
end
