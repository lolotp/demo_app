class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :content
      t.string :file_url
      t.integer :user_id
      t.integer :view_count
      t.integer :like_count
      t.integer :rating
      t.float :longitude
      t.float :latitude

      t.timestamps
    end
    add_index :posts, [:user_id, :created_at] 
  end
end
