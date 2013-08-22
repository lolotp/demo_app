class AddIndexToReceiverIdNotification < ActiveRecord::Migration
  def change
    add_index :notifications, :receiver_id
  end
end
