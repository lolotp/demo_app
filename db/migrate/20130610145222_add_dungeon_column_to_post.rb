class AddDungeonColumnToPost < ActiveRecord::Migration
  def change
    add_column :posts, :dungeon_id, :integer
    add_index  :posts, :dungeon_id
  end
end
