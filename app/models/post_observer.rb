class PostObserver < ActiveRecord::Observer
  observe :post
  def after_create(post)
    Resque.enqueue(InformUserOfNewPostResqueJob, post.id)
  end
end
