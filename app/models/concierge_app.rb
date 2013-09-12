class ConciergeApp < ActiveRecord::Base
  attr_accessible :iso_country_code, :category, :app_store_link, :google_play_link, :link
end
