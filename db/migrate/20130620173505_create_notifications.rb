class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :content
      t.boolean :viewed
      t.integer :receiver_id
    
      t.timestamps
    end
  end
end
