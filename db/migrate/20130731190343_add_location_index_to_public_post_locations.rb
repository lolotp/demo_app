class AddLocationIndexToPublicPostLocations < ActiveRecord::Migration
  def up
    execute "CREATE INDEX public_post_location_location_index ON public_post_locations USING gist(ll_to_earth(latitude,longitude))"
  end
  def down
    execute "DROP INDEX public_post_location_location_index"
  end
end

