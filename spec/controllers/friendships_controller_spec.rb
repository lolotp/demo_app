require 'spec_helper'

describe FriendshipsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user }

  describe "creating a friendship with Ajax" do

    it "should increment the Friend count" do
      expect do
        xhr :post, :create, friendship: { friend_id: other_user.id }
      end.to change(Friendship, :count).by(2)
    end

    it "should respond with success" do
      xhr :post, :create, friendship: { friend_id: other_user.id }
      response.should be_success
    end
  end

  describe "destroying a friendship with Ajax" do

    before do 
      user.request_friend!(other_user)
      other_user.accept_friend!(user)
    end
    let(:friendship) { user.friendships.find_by_friend_id(other_user) }

    it "should decrement the Friendship count" do
      expect do
        xhr :delete, :destroy, id: friendship.id
      end.to change(Friendship, :count).by(-2)
    end

    it "should respond with success" do
      xhr :delete, :destroy, id: friendship.id
      response.should be_success
    end
  end
end


