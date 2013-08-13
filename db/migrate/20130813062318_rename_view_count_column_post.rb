class RenameViewCountColumnPost < ActiveRecord::Migration
  def change
    rename_column :posts, :view_count, :ban_count
  end
end
