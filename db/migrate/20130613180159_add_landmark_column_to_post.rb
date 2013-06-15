class AddLandmarkColumnToPost < ActiveRecord::Migration
  def change
    add_column :posts, :landmark_id, :integer
    add_index  :posts, :landmark_id
  end
end
