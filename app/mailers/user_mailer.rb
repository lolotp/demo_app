class UserMailer < ActionMailer::Base
  default from: "noreply@memcap.com"

  def reset_password_email(user_id)
    user = User.find(user_id)
    @url = reset_password_user_path(user, :only_path => false, :reset_password_token => user.remember_token)
    mail(to: user.email, subject: 'Your password reset link')
  end
end
