class CreateTalks < ActiveRecord::Migration
  def change
    create_table :talks do |t|
      t.string :name
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.string :topics
      t.integer :event_id

      t.timestamps
    end
    add_index :talks, :event_id
  end
end
