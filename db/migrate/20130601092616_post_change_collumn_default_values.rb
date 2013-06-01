class PostChangeCollumnDefaultValues < ActiveRecord::Migration
  def change
    change_column :posts, :view_count, :integer, :default => 0
    change_column :posts, :like_count, :integer, :default => 0
    change_column :posts, :longitude, :float, :default => 0
    change_column :posts, :latitude, :float, :default => 0 
  end
end
