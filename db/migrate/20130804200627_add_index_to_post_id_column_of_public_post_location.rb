class AddIndexToPostIdColumnOfPublicPostLocation < ActiveRecord::Migration
  def change
    add_index :public_post_locations, :post_id, :unique => true
  end
end
