class Comment < ActiveRecord::Base
  attr_accessible :content
  belongs_to :post
  belongs_to :user

  validates :content, presence: true
  validates :user, presence: true
  validates :post, presence: true
end
