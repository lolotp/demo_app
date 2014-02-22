class AddPostalCodeColumnToTalks < ActiveRecord::Migration
  def change
    add_column :talks, :postal_code, :integer
  end
end
