class AddLocationIndexToPost < ActiveRecord::Migration
  def up
    execute "CREATE INDEX post_location_index ON posts USING gist(ll_to_earth(latitude,longitude))"
  end
  def down
    execute "DROP INDEX post_location_index"
  end
end
