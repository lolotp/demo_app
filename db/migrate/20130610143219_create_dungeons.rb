class CreateDungeons < ActiveRecord::Migration
  def change
    create_table :dungeons do |t|
      t.string :description
      t.string :file_url
      t.integer :user_id
      t.integer :view_count
      t.integer :like_count
      t.integer :rating
      t.float :longitude
      t.float :latitude

      t.timestamps
    end

    add_index :dungeons, [:user_id, :created_at]
  end
end
