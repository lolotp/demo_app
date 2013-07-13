class Follow < ActiveRecord::Base
  attr_accessible :followee_id
  belongs_to :user
  belongs_to :followee, :class_name => 'User'
  
  validates :user_id, presence: true
  validates :followee_id, presence: true
end
