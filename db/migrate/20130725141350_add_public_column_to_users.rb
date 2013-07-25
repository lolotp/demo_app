class AddPublicColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :public, :boolean, :default => false
    add_index  :users, :public
  end
end
