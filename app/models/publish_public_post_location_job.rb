require 'resque-retry'

#this job pastes a new post to the global location table so that user in various places in the world can query these posts
class PublishPublicPostLocationJob
  extend Resque::Plugins::Retry unless Rails.env.test?
  
  @queue = :publish_location_jobs
  @retry_limit = 10

  def self.perform(post_id)
    puts "beginning publishing post to geo table"    
    post = Post.find_by_id(post_id)
    if (post.privacy_option != 'public' or (not post) ) 
      return
    end
    
    puts "creating location data"
    public_post_location = PublicPostLocation.new(:latitude => post.latitude, :longitude => post.longitude)
    public_post_location.post_id = post_id
    if not public_post_location.save
      #if entry already exists in the table
      if (PublicPostLocation.find_by_id(post.id))
        puts "post id exists exiting"
        return #consider job successful
      else
        #retry job by raising the error
        raise public_post_location.errors
      end #end
    end #unless
    puts "end job"
  end #def 

end
