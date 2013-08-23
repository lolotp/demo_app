require 'spec_helper'

describe PostsController do
  let (:user) { FactoryGirl.create(:user) }
  let (:other_user) {  FactoryGirl.create(:user) }
  before do
    user.request_friend!(other_user)
    other_user.accept_friend!(user)
    sign_in(user)
    Post.observers.enable :post_observer
  end
  describe "POST #create public post" do
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

  describe "POST #create friends post" do
    before do
      post :create, :post => {:privacy_option => "friends", :file_url => "abc", :thumbnail_url => "abc"}, :mobile => 1
    end
    
    it "should be ok" do
      response.body.should == "ok"
    end
    
    it "should create a new post" do
      post = assigns(:post)
      post.id {should_not == nil}
    end
    
    it "should publish the post to location feed of own user" do
      location_feeds = user.user_location_feeds
      location_feeds.count { should_not ==0 }
      location_feeds.first.post_id { should == assigns(:post)[:id] }
    end

    it "should publish the post to location feed of friend" do
      location_feeds = other_user.user_location_feeds
      location_feeds.count { should_not ==0 }
      location_feeds.first.post_id { should == assigns(:post)[:id] }
    end
  end
end
