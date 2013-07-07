class AddCategoryColumnToLandmark < ActiveRecord::Migration
  def change
    add_column :landmarks, :category, :string, default: "Others"
  end
end
