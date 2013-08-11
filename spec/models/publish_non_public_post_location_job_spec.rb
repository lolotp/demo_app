require 'spec_helper'
require 'spec_comment_helpers'

describe PublishNonPublicPostLocationJob do
  include SpecCommentHelpers
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) {  FactoryGirl.create(:user) }
  before do
    user.request_friend!(other_user)
    other_user.accept_friend!(user)
    @post = user.posts.build(content: "sample review", file_url: "http://", thumbnail_url: "asdf", latitude: 120.0, longitude: 120.0, rating: 5, privacy_option: "friends" )
    @post.save
    PublishNonPublicPostLocationJob.perform(@post.id)
  end

  describe "post owner should have the post in the feed" do
    subject { user }
    its(:user_location_feeds) { should_not be_empty}
    describe "feeds should have a post with corresponding post id" do
      subject { user.user_location_feeds.first.post_id }
      it { should ==@post.id }
    end
  end

  describe "post owner friend should have the post in the feed" do
    subject { other_user }
    its(:user_location_feeds) { should_not be_empty}
    describe "feeds should have a post with corresponding post id" do
      subject { other_user.user_location_feeds.first.post_id }
      it { should ==@post.id }
    end
  end

end
