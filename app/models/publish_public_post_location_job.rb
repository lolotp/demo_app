class PublishPublicPostLocationJob < Struct.new(:post)
  def perform
    public_post_location = PublicPostLocation.create(:latitude => post.latitude, :longitude => post.longitude, :post_id => post.id)
    public_post_location.save
  end
end
