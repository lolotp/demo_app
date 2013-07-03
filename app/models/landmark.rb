class Landmark < ActiveRecord::Base
  attr_accessible :name, :description, :file_url, :latitude, :longitude, :rating
  belongs_to :user

  has_many :posts

  def self.feed_by_social_radius(cur_lat, cur_long, levels)
    radius_filter = ""
    levels.each do |level|
      dist = level[:dist]
      popularity = level[:popularity]
      level_filter = "(earth_box(ll_to_earth(#{cur_lat},#{cur_long}), #{dist}) @> ll_to_earth(latitude, longitude) AND view_count+like_count > #{popularity})"
      if (radius_filter != "") 
        radius_filter += " OR "
      end
      radius_filter += level_filter
    end
    where("#{radius_filter}")
  end
end
