require 'spec_helper'

describe PostsController do
  let (:user) { FactoryGirl.create(:user) }
  before do
    sign_in(user)
    Post.observers.enable :post_observer
  end
  describe "POST #create" do
    before do
      post :create, :post => {:privacy_option => "public", :file_url => "abc", :thumbnail_url => "abc"}, :mobile => 1
    end
    
    it "should be ok" do
      response.body.should == "ok"
    end
    
    it "should create a new post" do
      post = assigns(:post)
      post.id {should_not == nil}
    end
    
    it "should publish the post to public_post_locations table" do
      public_post_location = PublicPostLocation.find_by_post_id(assigns(:post)[:id])
      public_post_location.id { should_not == nil }
    end

  end
end
