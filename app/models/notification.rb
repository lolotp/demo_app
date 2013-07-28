class Notification < ActiveRecord::Base
  attr_accessible :content, :viewed
  
  belongs_to :receiver, :class_name => 'User'

  def self.send_notification(content, user)
    notification = user.notifications.build(:content => content)
    notification.save
  end
end
