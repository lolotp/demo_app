class UserObserver < ActiveRecord::Observer
  observe :user

  def after_create(user)
  end

end
