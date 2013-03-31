require 'spec_helper'

describe Friendship do

  let(:friend1) { FactoryGirl.create(:user) }
  let(:friend2) { FactoryGirl.create(:user) }
  let(:friendship1) { friend1.friendships.build(friend_id: friend2.id) }
  let(:friendship2) { friend2.friendships.build(friend_id: friend1.id) }

  subject { friendship1 }
  before do
    friendship1.status = "pending"
    friendship2.status = "requested"
  end

  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        Friendship.new(user_id: friend1.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end
  
  describe "friendship methods" do    
    it { should respond_to(:user) }
    it { should respond_to(:friend) }
    its(:user) { should == friend1 }
    its(:friend) { should == friend2 }
  end
  
  describe "when friend is not present" do
    before { friendship1.friend = nil }
    it { should_not be_valid }
  end

  describe "when user id is not present" do
    before { friendship1.user_id = nil }
    it { should_not be_valid }
  end
end


