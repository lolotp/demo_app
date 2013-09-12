class CreateConciergeApps < ActiveRecord::Migration
  def change
    create_table :concierge_apps do |t|
      t.string   :iso_country_code
      t.string   :category
      t.string   :app_store_link
      t.string   :google_play_link
      t.string   :link

      t.timestamps
    end

    add_index :concierge_apps, :iso_country_code
    add_index :concierge_apps, [:iso_country_code, :category], :unique => true
  end
end
