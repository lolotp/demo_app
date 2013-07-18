class AddReleaseColumnToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :release, :datetime
    add_index  :posts, :release
  end
end
