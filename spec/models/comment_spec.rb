require 'spec_helper'
require 'spec_comment_helpers'

describe Comment do
  include SpecCommentHelpers
  let(:user) { FactoryGirl.create(:user) }
  before do
    @post = user.posts.build(content: "sample review", file_url: "http://", thumbnail_url: "asdf", latitude: 120.0, longitude: 120.0, rating: 5, privacy_option: "public" )
    @post.save
    @comment = user.comments.build(content: "hahaha")
    @comment.post_id = @post.id
  end

  subject {@comment}

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) } 
  it { should respond_to(:post) }
  it { should respond_to(:post_id) }

  describe "ids of user who commented on a post" do
   
    before do
      comments_from_unique_user = comment_on_a_post_with_3_unique_user (@post)
      @comment1 = comments_from_unique_user[0]
      @comment2 = comments_from_unique_user[1]
      @comment3 = comments_from_unique_user[2]
      comments_grouped_by_user_ids = Comment.on_post_by_unqiue_users(@post, Time.now + 10.days)
      @user_ids = comments_grouped_by_user_ids.map { |c| c.attributes.to_options }
    end
    subject { @user_ids }
    describe "list of user ids should have all users who have commented on it with the time they did" do
      it { should include({:user_id => @comment1.user_id, :created_at => @comment1.created_at }) }
      it { should include({:user_id => @comment2.user_id, :created_at => @comment2.created_at }) }
      it { should include({:user_id => @comment3.user_id, :created_at => @comment3.created_at }) }
    end
  end

end
