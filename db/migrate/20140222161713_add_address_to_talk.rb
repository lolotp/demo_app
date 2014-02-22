class AddAddressToTalk < ActiveRecord::Migration
  def change
    add_column :talks, :address, :string
  end
end
