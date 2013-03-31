require 'spec_helper'

describe "UserPages" do
  subject { page }
  
  describe "index" do
    before do
      sign_in FactoryGirl.create(:user)
      FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
      FactoryGirl.create(:user, name: "Ben", email: "ben@example.com")
      visit users_path
    end

    it { should have_selector('title', text: 'All users') }
    it { should have_selector('h1',    text: 'All users') }

    describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end
    
    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  describe "signup page" do
    before { visit signup_path }
    
    it { should have_selector('h1',    text: 'Sign up') }
    it { should have_selector('title', text: full_title('Sign up')) }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:p1) { FactoryGirl.create(:post, user: user, content: "Foo") }
    let!(:p2) { FactoryGirl.create(:post, user: user, content: "Bar") }
    
    before do
      sign_in user
      visit user_path(user)
    end
    
    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
    
    describe "posts" do
      it { should have_content(p1.content) }
      it { should have_content(p2.content) }
      it { should have_content(user.posts.count) }
    end
    
    describe "friend/unfriend buttons" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "adding a user as friend" do
        before { visit user_path(other_user) }

        it "should increment the pending friends count" do
          expect do
            click_button "Add friend"
          end.to change(user.pending_friends, :count).by(1)
        end

        it "should increment the other user's requested friends count" do
          expect do
            click_button "Add friend"
          end.to change(other_user.requested_friends, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Add friend" }
          it { should have_selector('input', value: 'Cancel pending request') }
        end
      end
      
      describe "accepting a friend request" do
        before do 
          other_user.request_friend!(user)
          visit user_path(other_user)
        end
        
        it "should increase the friends count" do
          expect do
            click_button "Accept pending request"
          end.to change(user.friends, :count).by(1)
        end
        
        it "should decrease the requested friends count" do
          expect do
            click_button "Accept pending request"
          end.to change(user.requested_friends, :count).by(-1)
        end
        
        it "should increase the other's friends count" do
          expect do
            click_button "Accept pending request"
          end.to change(other_user.friends, :count).by(1)
        end
        
        it "should decrease the other's pending friends count" do
          expect do
            click_button "Accept pending request"
          end.to change(other_user.pending_friends, :count).by(-1)
        end
        
        describe "toggling the button" do
          before { click_button "Accept pending request" }
          it { should have_selector('input', value: 'Unfriend') }
        end
      end
      
      describe "cancelling a friend request" do
        before do 
          user.request_friend!(other_user)
          visit user_path(other_user)
        end
        
        it "should decrease pending friends count" do
          expect do
            click_button "Cancel pending request"
          end.to change(user.pending_friends, :count).by(-1)
        end
        
        it "should decrease other's requested friends count" do
          expect do
            click_button "Cancel pending request"
          end.to change(other_user.requested_friends, :count).by(-1)
        end
        
        describe "toggling the button" do
          before { click_button "Cancel pending request" }
          it { should have_selector('input', value: 'Add friend') }
        end
      end

      describe "unfriending a user" do
        before do
          user.request_friend!(other_user)
          other_user.accept_friend!(user)
          visit user_path(other_user)
        end

        it "should decrement the friends count" do
          expect do
            click_button "Unfriend"
          end.to change(user.friends, :count).by(-1)
        end

        it "should decrement the other user's friends count" do
          expect do
            click_button "Unfriend"
          end.to change(other_user.friends, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unfriend" }
          it { should have_selector('input', value: 'Add friend') }
        end
      end
    end
  end
  
  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        it { should have_link('Sign out') }
      end

    end
  end
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user) 
    end

    describe "page" do
      it { should have_selector('h1',    text: "Update your profile") }
      it { should have_selector('title', text: "Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end
    
    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

  describe "friends" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      user.request_friend!(other_user)
      other_user.accept_friend!(user)
    end

    describe "other friend" do
      before do
        sign_in other_user
        visit friends_user_path(other_user)
      end

      it { should have_selector('title', text: full_title('Friends')) }
      it { should have_selector('h3', text: 'Friends') }
      it { should have_link(user.name, href: user_path(user)) }
    end
    
    describe "myself" do
      before do
        sign_in user
        visit friends_user_path(user)
      end

      it { should have_selector('title', text: full_title('Friends')) }
      it { should have_selector('h3', text: 'Friends') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end
  end
end
