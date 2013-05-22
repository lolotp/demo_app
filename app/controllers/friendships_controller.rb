class FriendshipsController < ApplicationController
  before_filter :signed_in_user
  before_filter :check_for_mobile, :only => [:create, :destroy, :update]
  
  def create
    @user = User.find(params[:friendship][:friend_id])
    current_user.request_friend!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
      format.json { current_user.friendships.find_by_friend_id(@user).status }
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
      format.json { current_user.friendships.find_by_friend_id(@user).status }
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
      format.json { current_user.friendships.find_by_friend_id(@user).status }
    end
  end
end
