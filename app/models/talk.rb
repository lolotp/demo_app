class Talk < ActiveRecord::Base
  attr_accessible :name, :description, :start_time, :end_time, :topics, :address, :postal_code
  belongs_to :event

end
