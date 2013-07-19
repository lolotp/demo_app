module PostsHelper
  def gen_radius_filter_query(cur_lat, cur_long, levels)
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
    radius_filter
  end

  def user_friend_query
    "SELECT friend_id FROM friendships
                         WHERE user_id = :user_id AND status='accepted'"
  end
end
