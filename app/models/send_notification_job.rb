class SendNotificationJob < Struct.new(:content, :user)
  def perform
     Notification.send_notification(content, user)
  end
end
