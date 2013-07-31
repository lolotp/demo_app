require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com", 
                     password: "foobar", password_confirmation: "foobar")
  end
  
  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:microposts) }
  it { should respond_to(:posts) }
  it { should respond_to(:post_feed) }
  it { should respond_to(:friendships) }
  it { should respond_to(:friends) }
  it { should respond_to(:pending_friends) }
  it { should respond_to(:requested_friends) }
  it { should respond_to(:friend?) }
  it { should respond_to(:request_friend!) }
  it { should respond_to(:accept_friend!) }
  it { should respond_to(:unfriend!) }
  it { should respond_to(:unviewed_notifications) }
  it { should respond_to(:follows) }
  it { should respond_to(:followees) }
  it { should respond_to(:follows) }
  it { should respond_to(:followers) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end
  
  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end
  
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end      
    end
  end
  
  describe "when email address is already taken" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      other_user.email = @user.email
      other_user.save
    end

    it { should_not be_valid }
  end

  describe "when email address is already taken" do
   let(:other_user) { FactoryGirl.create(:user) }
    before do
      other_user.email = @user.email.upcase
      other_user.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end
  
  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end
  
  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end
  
  describe "micropost associations" do

    before { @user.save }
    let!(:older_micropost) do 
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [newer_micropost, older_micropost]
    end
    
    it "should destroy associated microposts" do
      microposts = @user.microposts.dup
      @user.destroy
      microposts.should_not be_empty
      microposts.each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
  end

  describe "post associations" do

    before { @user.save }
    let!(:older_post) do 
      FactoryGirl.create(:post, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_post) do
      FactoryGirl.create(:post, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right posts in the right order" do
      @user.posts.should == [newer_post, older_post]
    end
    
    it "should destroy associated posts" do
      posts = @user.posts.dup
      @user.destroy
      posts.should_not be_empty
      posts.each do |post|
        Post.find_by_id(post.id).should be_nil
      end
    end
    
    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:post, user: FactoryGirl.create(:user))
      end
      let(:friend) { FactoryGirl.create(:user) }

      before do
        @user.request_friend!(friend)
        friend.accept_friend!(@user)
        3.times { friend.posts.create!(content: "Lorem ipsum", file_url: "tt", thumbnail_url: "tt") }
      end
      
      its(:post_feed) { should_not include(unfollowed_post) }
      its(:post_feed) do
        friend.posts.each do |p|
          should include(p)
        end
      end
    end
  end
  
  describe "friend request" do
    let(:other_user) { FactoryGirl.create(:user) }    
    before do
      @user.save
      @user.request_friend!(other_user)
    end
    
    it { should_not be_friend(other_user) }
    its(:pending_friends) { should include(other_user) }
    
    describe "other friend" do
      subject { other_user }
      its(:requested_friends) { should include(@user) }
    end
  end
  
  describe "friending" do
    let(:other_user) { FactoryGirl.create(:user) }    
    before do
      @user.save
      @user.request_friend!(other_user)
      other_user.accept_friend!(@user)
    end

    it { should be_friend(other_user) }
    its(:friends) { should include(other_user) }
    
    describe "other friend" do
      subject { other_user }
      its(:friends) { should include(@user) }
    end
    
    describe "and unfriend" do
      before { @user.unfriend!(other_user) }

      it { should_not be_friend(other_user) }
      its(:friends) { should_not include(other_user) }
      
      describe "other friend" do
        subject { other_user }
        its(:friends) { should_not include(@user) }
      end
    end
  end

#  describe "sending notifications" do
#    let(:other_user) { FactoryGirl.create(:user) }
#    before do
#      @user.save
#      @user.request_friend!(other_user)
#    end
    
#    describe "notification for other user should exist" do
#      subject { other_user }
#      its(:notifications) { should_not be_empty }
#    end

#    describe "notification should have user's name" do
#      subject { other_user.notifications.first }
#      its (:content) { should include(@user.name) }
#    end
#  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followees) { should include(other_user) }

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followees) { should_not include(other_user) }
    end
  end
end

