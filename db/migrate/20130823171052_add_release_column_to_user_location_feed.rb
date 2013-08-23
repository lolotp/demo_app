class AddReleaseColumnToUserLocationFeed < ActiveRecord::Migration
  def change
    add_column :user_location_feeds, :release, :datetime
  end
end
