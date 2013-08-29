class SendResetPasswordEmailResqueJob
  extend Resque::Plugins::Retry
  @queue = "user_login"
  
  @retry_limit = 3
  def self.perform(user_id)
    UserMailer.reset_password_email(User.find(user_id)).deliver
  end
end
