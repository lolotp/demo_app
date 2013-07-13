class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.integer :user_id
      t.integer :followee_id

      t.timestamps
    end

    add_index :follows, :user_id
    add_index :follows, :followee_id
    add_index :follows, [:user_id, :followee_id], unique: true
  end
end
