class Talk < ActiveRecord::Base
  attr_accessible :name, :description, :start_time, :end_time, :topics, :address
  belongs_to :event

end
