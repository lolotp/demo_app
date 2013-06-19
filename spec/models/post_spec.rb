require 'spec_helper'

describe Post do
  let(:user) { FactoryGirl.create(:user) }
  before { @post = user.posts.build(content: "sample review", file_url: "http://", latitude: 120.0, longitude: 120.0, rating: 5) }

  subject { @post }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:latitude) }
  it { should respond_to(:longitude) }
  it { should respond_to(:view_count) }
  it { should respond_to(:like_count) }
  it { should respond_to(:landmark_id) }

  its(:user) { should == user }

  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        Post.new(user_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow access to view_count" do
      expect do
        Post.new(view_count: 0)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end  
    it "should not allow access to like_count" do
      expect do
        Post.new(like_count: 0)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "with blank content" do
    before { @post.content = " " }
    it { should_not be_valid }
  end

  describe "when user_id is not present" do
    before { @post.user_id = nil }
    it { should_not be_valid }
  end

end
