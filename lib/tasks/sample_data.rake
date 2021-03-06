namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.create!(name: "lolo",
                 email: "lolotp@hotmail.com",
                 password: "123456",
                 password_confirmation: "123456")
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
    
    users = User.all(limit: 6)
      50.times do
        content = Faker::Lorem.sentence(5)
        users.each { |user| user.posts.create!(content: content, latitude: 120.0, longitude: 120.0, rating: 5) }
      end
      
    make_relationships
  end
  
  def make_relationships
    users = User.all
    user  = users.first
    friends = users[2..50]
    friends.each do |f| 
      user.request_friend!(f)
      f.accept_friend!(user)
    end
  end
end


