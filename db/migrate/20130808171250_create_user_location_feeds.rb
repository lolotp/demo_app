class CreateUserLocationFeeds < ActiveRecord::Migration
  def up
    create_table :user_location_feeds do |t|
      t.integer :post_id
      t.integer :user_id
      
      t.float :longitude
      t.float :latitude

      t.timestamps
    end

    add_index :user_location_feeds, :post_id, :unique => true
    add_index :user_location_feeds, :user_id
    execute "CREATE INDEX user_location_feeds_location_index ON user_location_feeds USING gist(ll_to_earth(latitude,longitude))"
  end
  def down
    execute "DROP INDEX user_location_feeds_location_index"
    remove_index :user_location_feeds, :user_id
    remove_index :user_location_feeds, :post_id
    drop_table :user_location_feeds
  end
end
