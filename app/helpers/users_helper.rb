require 'aws-sdk'

module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    image_tag(user.gravatar_url, alt: user.name, class: "gravatar")
  end
  
  def s3_avatar_url(user)
    s3 = AWS::S3.new({
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    })
    #user avatar is stored as an image file with the same name as user.email on amazon s3
    object = s3.buckets[ ENV['IMAGE_AVATAR_BUCKET'] ].objects[user.email]

    url = object.url_for(:read,:expires => 20.minutes.from_now, :secure => true )
    
  end

  def aes256_encrypt(key, data)
    key = Digest::SHA256.digest(key) if(key.kind_of?(String) && 32 != key.bytesize)
    aes = OpenSSL::Cipher.new('AES-256-CBC')
    aes.encrypt
    aes.key = key
    aes.update(data) + aes.final
  end
  
  def encrypted_aliyun_oss_credentials(key)
    data = { :oss_access_key_id => ENV['OSS_ACCESS_KEY_ID'], :oss_secret_access_key => ENV['OSS_SECRET_ACCESS_KEY'] }
    Base64.encode64(aes256_encrypt(key, data.to_s)).encode('utf-8')
  end

  def avatar_image_tag(user)
    image_tag(avatar_user_path(user), class: "gravatar", size: "50x50")
  end
end
