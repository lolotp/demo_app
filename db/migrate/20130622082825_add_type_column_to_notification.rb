class AddTypeColumnToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :type, :string
    add_index  :notifications, :type
  end
end
