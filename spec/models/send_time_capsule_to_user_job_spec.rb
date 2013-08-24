require 'spec_helper'

describe SendTimeCapsuleToUserJob do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) {  FactoryGirl.create(:user) }
  before do
    user.request_friend!(other_user)
    other_user.accept_friend!(user)
    @post = user.posts.build(content: "sample review", file_url: "http://", thumbnail_url: "asdf", latitude: 120.0, longitude: 120.0, rating: 5, privacy_option: "friends" )
    @post.save
  end

  describe "should send notifications to user if enqueued and carried out correctly" do
    before do
      SendTimeCapsuleToUserJob.perform(user.id, other_user.id, @post.id)
    end

    subject { other_user }
    its(:notifications) { should_not be_empty}
    describe "notifications of other user should contain the post id and id of sender" do
      subject { other_user.notifications.first.content }
      it { should include(user.id.to_s) }
      it { should include(@post.id.to_s) }
    end
  end
end
