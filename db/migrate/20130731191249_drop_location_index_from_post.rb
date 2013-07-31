class DropLocationIndexFromPost < ActiveRecord::Migration
  def up
    execute "DROP INDEX post_location_index"
  end

  def down
    execute "CREATE INDEX post_location_index ON posts USING gist(ll_to_earth(latitude,longitude))"
  end
end
