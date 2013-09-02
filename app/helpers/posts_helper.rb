require 'aliyun/oss'

module PostsHelper
  def gen_radius_filter_query(cur_lat, cur_long, levels)
    radius_filter = ""
    levels.each do |level|
      dist = level[:dist]
      popularity = level[:popularity]
      level_filter = "(earth_box(ll_to_earth(#{cur_lat},#{cur_long}), #{dist}) @> ll_to_earth(latitude, longitude) AND like_count > #{popularity})"
      if (radius_filter != "") 
        radius_filter += " OR "
      end
      radius_filter += level_filter
    end
    radius_filter
  end
  
  def s3_thumbnail_url(post)
    s3 = AWS::S3.new({
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    })
    #user avatar is stored as an image file with the same name as user.email on amazon s3
    object = s3.buckets[ ENV['USER_MEDIA_BUCKET'] ].objects[post.thumbnail_url]

    object.url_for(:read,:expires => 20.minutes.from_now, :secure => true )
  end

  def oss_thumbnail_url(post)
    Aliyun::OSS::Base.establish_connection!(
      :access_key_id     => ENV['OSS_ACCESS_KEY_ID'], 
      :secret_access_key => ENV['OSS_SECRET_ACCESS_KEY']
    )
    Aliyun::OSS::OSSObject.url_for(post.thumbnail_url, ENV['OSS_BUCKET'], :expires_in => 60 * 20)
  end

  def oss_media_url(post)
    Aliyun::OSS::Base.establish_connection!(
      :access_key_id     => ENV['OSS_ACCESS_KEY_ID'], 
      :secret_access_key => ENV['OSS_SECRET_ACCESS_KEY']
    )
    Aliyun::OSS::OSSObject.url_for(post.file_url, ENV['OSS_BUCKET'], :expires_in => 60 * 20) #expire in 20 minutes
  end

  def post_thumbnail_image_tag(post)
    image_tag(thumbnail_post_path(post), alt: "broken link", class: "gravatar")
  end

  def s3_media_url(post)
    s3 = AWS::S3.new({
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    })
    #user avatar is stored as an image file with the same name as user.email on amazon s3
    object = s3.buckets[ ENV['USER_MEDIA_BUCKET'] ].objects[post.file_url]

    object.url_for(:read,:expires => 20.minutes.from_now, :secure => true )
  end

  def user_friend_query
    "SELECT friend_id FROM friendships
                         WHERE user_id = :user_id AND status='accepted'"
  end
end
