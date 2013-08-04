require 'spec_helper'
require 'spec_comment_helpers'

describe InformUserOfNewCommentResqueJob do
  include SpecCommentHelpers
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) {  FactoryGirl.create(:user) }
  before do
    @post = user.posts.build(content: "sample review", file_url: "http://", thumbnail_url: "asdf", latitude: 120.0, longitude: 120.0, rating: 5, privacy_option: "public" )
    @post.save
    comments_from_unique_user = comment_on_a_post_with_3_unique_user (@post)
    @comment1 = comments_from_unique_user[0]
    @comment2 = comments_from_unique_user[1]
    @comment3 = comments_from_unique_user[2]
    @comment = other_user.comments.build(content: "hahaha")
    @comment.post_id = @post.id
    @comment.save
    job = InformUserOfNewCommentResqueJob
    InformUserOfNewCommentResqueJob.perform(@comment.id, Time.now + 2.days, true)
  end

  describe "post owner should be informed" do
    subject { user }
    its(:notifications) { should_not be_empty}
    describe "notifications should have id of user who commented on and post id" do
      subject { user.notifications.first.content }
      it { should include(other_user.id.to_s) }
      it { should include(@post.id.to_s) }
    end
  end

  describe "post owner should be informed" do
    before do
      @commented_user = User.find_by_id(@comment1.user_id)
    end
    subject { @commented_user }
    its(:notifications) { should_not be_empty}
    describe "notifications should have id of user who commented on and post id" do
      subject { @commented_user.notifications.first.content }
      it { should include(other_user.id.to_s) }
      it { should include(@post.id.to_s) }
    end
  end

end
