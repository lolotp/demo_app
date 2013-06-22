class FriendshipsController < ApplicationController
  before_filter :check_for_mobile, :only => [:create, :destroy, :update]
  before_filter :signed_in_user
  before_filter :correct_user, :only => [:update, :destroy]
  
  def create
    @user = User.find(params[:friendship][:friend_id])
    current_user.request_friend!(@user)
    friendship = current_user.friendships.find_by_friend_id(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
      if (friendship)
        format.json { render json: {:status => friendship.status, :id => friendship.id } }
      else
        format.json { render json: {:status => friendship, :id => friendship } }
      end
    end
  end

  def destroy
    f = Friendship.find(params[:id])
    @user = f.friend
    if (f.status == 'accepted')
      current_user.unfriend!(@user)
    elsif (f.status == "pending")
      current_user.cancel_request!(@user)
    elsif (f.status == "requested")
      current_user.decline_request!(@user)
    end
    friendship = current_user.friendships.find_by_friend_id(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
      if (friendship)
        format.json { render json: {:status => friendship.status, :id => friendship.id } }
      else
        format.json { render json: {:status => friendship, :id => friendship } }
      end
    end
  end
  
  def update
    f = Friendship.find(params[:id])
    @user = f.friend
    if f.status == "requested"
      current_user.accept_friend!(@user)
    end
    friendship = current_user.friendships.find_by_friend_id(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
      if (friendship)
        format.json { render json: {:status => friendship.status, :id => friendship.id } }
      else
        format.json { render json: {:status => friendship, :id => friendship } }
      end
    end
  end

  private 
    def correct_user
      @friendship = current_user.friendships.find_by_id(params[:id])
      unauthorized_result if @friendship.nil?
    end
end
