class PostReport < ActiveRecord::Base
  attr_accessible :reason, :category
  belongs_to :user
  belongs_to :post

  def self.recently_reported_posts_ids( after_time )
    select("DISTINCT post_id").where("created_at > :after_time", :after_time => after_time)
  end

end
