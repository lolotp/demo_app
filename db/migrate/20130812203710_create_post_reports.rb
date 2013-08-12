class CreatePostReports < ActiveRecord::Migration
  def change
    create_table :post_reports do |t|
      t.integer :user_id
      t.integer :post_id
      t.string  :category
      t.string  :reason

      t.timestamps
    end
    add_index :post_reports, :post_id
    add_index :post_reports, :user_id
  end
end
