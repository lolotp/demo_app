require 'aws-sdk'

module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    image_tag(user.gravatar_url, alt: user.name, class: "gravatar")
  end
  
  def avatar_for(user)
    s3 = AWS::S3.new({
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    })
    #user avatar is stored as an image file with the same name as user.email on amazon s3
    object = s3.buckets[ ENV['IMAGE_AVATAR_BUCKET'] ].objects[user.email]

    url = object.url_for(:read,:expires => 20.minutes.from_now, :secure => true )
    image_tag(url, alt: user.name, class: "gravatar", size: 50)
  end
end
