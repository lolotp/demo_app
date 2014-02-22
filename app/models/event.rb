class Event < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :talks, dependent: :destroy
end
