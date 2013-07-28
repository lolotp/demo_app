class AddDefaultValueToViewedColumnOfNotification < ActiveRecord::Migration
  def change
    change_column :notifications, :viewed, :boolean, :default => false
  end
end
