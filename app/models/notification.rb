class Notification < ActiveRecord::Base
  attr_accessible :content, :viewed
  
  belongs_to :receiver, :class_name => 'User'
end
