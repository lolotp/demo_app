require 'spec_helper'

describe Notification do
  let(:user) { FactoryGirl.create(:user) }
  before { @notification = user.notifications.build(content: "sample notification", viewed: false) }

  subject { @notification }

  it { should respond_to(:content) }
  it { should respond_to(:receiver_id) }
  it { should respond_to(:receiver) }
  it { should respond_to(:viewed) }

  describe "send notification after adding friend" do
    before do
      @friend = FactoryGirl.create(:user)
      @friend.save
      user.request_friend!(@friend)
    end

    it { should respond_to(:viewed) }
  end
end
