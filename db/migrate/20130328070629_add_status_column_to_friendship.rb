class AddStatusColumnToFriendship < ActiveRecord::Migration
  def change
    add_column :friendships, :status, :string
    add_index  :friendships, :status
  end
end
