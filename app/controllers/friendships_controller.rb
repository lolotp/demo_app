class FriendshipsController < ApplicationController
  before_filter :signed_in_user
  
  def create
    @user = User.find(params[:friendship][:friend_id])
    current_user.request_friend!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    f = Friendship.find(params[:id])
    @user = f.friend
    if (f.status == 'accepted')
      current_user.unfriend!(@user)
    elsif (f.status == "pending")
      current_user.cancel_request!(@user)
    end
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
  
  def update
    f = Friendship.find(params[:id])
    @user = f.friend
    if f.status == "requested"
      current_user.accept_friend!(@user)
    end
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
