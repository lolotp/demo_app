class AddPostedAtColumnToPost < ActiveRecord::Migration
  def change
    add_column :posts, :posted_at, :datetime
  end
end
