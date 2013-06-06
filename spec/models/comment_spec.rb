require 'spec_helper'

describe Comment do
  let(:user) { FactoryGirl.create(:user) }
  before do
    @post = user.posts.build(content: "sample review", file_url: "http://", latitude: 120.0, longitude: 120.0, rating: 5)
    @comment = user.comments.build(content: "hahaha")
    @comment.post_id = @post.id
  end

  subject {@comment}

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) } 
  it { should respond_to(:post) }
  it { should respond_to(:post_id) }
  
end
