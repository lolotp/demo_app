class LandmarkChangeColumnDefaultValues < ActiveRecord::Migration
  def change
    change_column :landmarks, :view_count, :integer, :default => 0
    change_column :landmarks, :like_count, :integer, :default => 0
    change_column :landmarks, :longitude, :float, :default => 0
    change_column :landmarks, :latitude, :float, :default => 0 
  end
end
