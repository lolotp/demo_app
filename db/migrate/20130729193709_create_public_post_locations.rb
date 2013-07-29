class CreatePublicPostLocations < ActiveRecord::Migration
  def change
    create_table :public_post_locations do |t|

      t.timestamps
    end
  end
end
