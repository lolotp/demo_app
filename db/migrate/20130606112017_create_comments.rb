class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :content
      t.integer :user_id
      t.integer :post_id

      t.timestamps
    end
    add_index :comments, [:post_id, :user_id, :created_at] 
  end
end
