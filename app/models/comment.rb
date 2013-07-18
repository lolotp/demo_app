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
end
