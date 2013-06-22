class AddIndexToNotificationsViewedColumn < ActiveRecord::Migration
  def change
    add_index :notifications, :viewed
  end
end
