class CreateUserLocationFeeds < ActiveRecord::Migration
  def change
    create_table :user_location_feeds do |t|
      t.integer :post_id
      t.integer :user_id
      
      t.float :longitude
      t.float :latitude

      t.timestamps
    end

    add_index :user_location_feeds, :post_id, :unique => true
    add_index :user_location_feeds, :user_id
  end
end
