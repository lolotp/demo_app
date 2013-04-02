class AddColumnPrivacyOptionsToPost < ActiveRecord::Migration
  def change
    add_column :posts, :privacy_option, :string, :default => "friends"
    add_index  :posts, :privacy_option
  end
end
