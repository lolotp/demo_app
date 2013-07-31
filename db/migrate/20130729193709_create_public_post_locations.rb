class CreatePublicPostLocations < ActiveRecord::Migration
  def change
    create_table :public_post_locations do |t|
      t.integer :post_id
      
      t.float :longitude
      t.float :latitude
      t.timestamps
    end
  end
end
