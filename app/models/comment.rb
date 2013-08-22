class Comment < ActiveRecord::Base
  attr_accessible :content
  belongs_to :post
  belongs_to :user

  validates :content, presence: true
  validates :user, presence: true
  validates :post, presence: true
  
  default_scope order: 'comments.created_at DESC'
  def as_json(options={})
      json_obj = super
      json_obj[:author_name] = self.user.name
      json_obj
  end

  def self.on_post_by_unqiue_users(post, before_time)
    unscoped.select("DISTINCT ON (user_id) user_id, created_at").where("post_id = :post_id AND created_at <= :before_time", :post_id => post.id, :before_time => before_time).order("user_id, created_at DESC")
  end
end
