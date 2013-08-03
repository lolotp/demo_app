module SpecCommentHelpers

  #comment on a post with various user returning a list of latest comment for each unique user
  def comment_on_a_post_with_3_unique_user (post)
    user1 = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user)
    user3 = FactoryGirl.create(:user)
    comment1 = user1.comments.build(content: "ASDf")
    comment1.post = @post
    comment1.save
    comment2 = user2.comments.build(content: "ASDf")
    comment2.post = @post
    comment2.save
    comment3 = user1.comments.build(content: "ASDf")
    comment3.post = @post
    comment3.save
    comment4 = user3.comments.build(content: "ASDf")
    comment4.post = @post
    comment4.save
    [comment4, comment3, comment2] 
  end
end
