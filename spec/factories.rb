FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  factory :micropost do
    content "Lorem ipsum"
    user
  end
  
  factory :post do
    content "sample review"
    file_url "http://www.imageurlhost.com/images/d4s7842xl4qduc8vj1w.jpg"
    thumbnail_url "http://www.imageurlhost.com/images/d4s7842xl4qduc8vj1w.jpg"
    latitude 120.0
    longitude 120.0
    rating    5
    privacy_option "public"
    user
  end

  factory :comment do
    content "comment"
    user
    post    
  end
end


