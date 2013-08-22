class AddConfirmationCodeColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_code, :integer
  end
end
