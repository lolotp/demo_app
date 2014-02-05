require 'spec_helper'
require 'spec_comment_helpers'

describe CommentObserver do
  include SpecCommentHelpers
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  before do
    @post = user.posts.build(content: "sample review", file_url: "http://", thumbnail_url: "asdf", latitude: 120.0, longitude: 120.0, rating: 5, privacy_option: "public" )
    @post.save
    @comment = other_user.comments.build(content: "hahaha")
    @comment.post_id = @post.id
  end

  subject {Resque.info[:pending]}

  it "when comment is saved to database" do
    OriginalResque = Resque
    Resque = double("Resque")
    Comment.observers.enable :comment_observer
    Resque.should_receive(:enqueue).with(InformUserOfNewCommentResqueJob, anything(), anything(), true)
    @comment.save
    Resque = OriginalResque
  end
    
end
