require 'spec_helper'

describe PublicPostLocation do
  let (:user) { FactoryGirl.create(:user) }
  let (:post) { FactoryGirl.create(:post, :user => user,:privacy_option => "public") }
  before do
    @public_post_location = PublicPostLocation.new()
    @public_post_location.post = post
    @public_post_location.latitude = post.latitude
    @public_post_location.longitude = post.longitude
  end
  
  subject { @public_post_location }
  it { should respond_to(:latitude) }
  it { should respond_to(:longitude) }
  it { should respond_to(:post) }
  describe "should be valid for saving"
  
end
