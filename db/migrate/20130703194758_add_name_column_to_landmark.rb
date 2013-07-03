class AddNameColumnToLandmark < ActiveRecord::Migration
  def change
    add_column :landmarks, :name, :string
    add_index  :landmarks, :name
  end
end
