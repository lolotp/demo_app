class CreatePostBans < ActiveRecord::Migration
  def change
    create_table :post_bans do |t|
      t.integer :post_id
      t.integer :user_id

      t.timestamps
    end
    
    add_index :post_bans, :post_id
    add_index :post_bans, [:post_id, :user_id], :unique => true
  end
end
