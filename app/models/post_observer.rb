#Everytime user post a new post, this observer model enqueue jobs that would paste this new post to the various feed of users
#who are supposed to see the post
class PostObserver < ActiveRecord::Observer
  observe :post
  
  def after_create(post)
    #enquing publish to location feed jobs
    if (post.privacy_option == "public")
      puts "enqueing task to resque to publish this feed to the global location table"
      Resque.enqueue(PublishPublicPostLocationJob,post.id)
    else
      puts "enqueing task to resque to publish this feed inidividual users' table who have the rights to see the post"
      Resque.enqueue(PublishNonPublicPostLocationJob, post.id)
    end

    #enquing publish to friend feed jobs

    #enquing publish to follow feed jobs
  end
end
