class Notification < ActiveRecord::Base
  attr_accessible :content, :viewed
    
  default_scope order: 'notifications.created_at DESC'
  
  belongs_to :receiver, :class_name => 'User'
  validates :receiver,  presence: true

  def self.send_notification(content, user)
    notification = user.notifications.build(:content => content)
    notification.save
  end
end
