class AddReleaseColumnToPublicPostLocation < ActiveRecord::Migration
  def change
    add_column :public_post_locations, :release, :datetime
  end
end
