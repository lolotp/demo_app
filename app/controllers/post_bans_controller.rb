class PostBansController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user

  def create
    post = Post.find(params[:post_ban][:post_id])
    post_ban = current_user.post_bans.build()
    post_ban.post_id = post.id
    @ok = true
    @post_id = post.id
    post_ban.transaction do
      post.increment!(:ban_count)
      @ok = @ok and post_ban.save
    end
    @ban_count = post.ban_count
    respond_to do |format|
        format.js
    end
  end

  def destroy
    post_ban = PostBan.find(params[:id])
    post = Post.find(post_ban.post_id)
    post_ban.transaction do
      post_ban.destroy
      post.decrement!(:ban_count)
    end
    @ok = post_ban.destroyed?
    @post_id = post_ban.post_id
    @ban_count = post.ban_count
    respond_to do |format|
        format.js
    end
  end
end
