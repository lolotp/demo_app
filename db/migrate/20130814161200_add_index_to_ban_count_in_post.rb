class AddIndexToBanCountInPost < ActiveRecord::Migration
  def change
    add_index :posts, :ban_count
  end
end
