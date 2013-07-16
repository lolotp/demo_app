class MakeLandmarkDescriptionAsLongAsPossible < ActiveRecord::Migration
  def up
    change_column :landmarks, :description, :text
  end
  def down
    change_column :landmarks, :description, :string
  end
end
