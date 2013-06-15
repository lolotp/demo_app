class RemoveDungeonColumnFromPost < ActiveRecord::Migration
  def up
    remove_column :posts, :dungeon_id
  end

  def down
    add_column :posts, :dungeon_id, :integer
    add_index  :posts, :dungeon_id
  end
end
