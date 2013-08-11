class ChangeIndexOnUserLocationFeedFromPostToCombinedIndexUserIdAndPostId < ActiveRecord::Migration
  def up
    remove_index :user_location_feeds, :post_id
    add_index :user_location_feeds, [:user_id, :post_id], :unique => true
  end

  def down
    remove_index :user_location_feeds, [:user_id, :post_id]
    add_index :user_location_feeds, :post_id
  end
end
