class CreatePublicPostLocations < ActiveRecord::Migration
  def change
    create_table :public_post_locations do |t|
      t.integer :post_id
      
      t.float :longitude
      t.float :latitude
      t.timestamps
    end

    add_index "public_post_locations", ["post_id"], :name => "index_public_post_locations_on_post_id", :unique => true
  end
end
