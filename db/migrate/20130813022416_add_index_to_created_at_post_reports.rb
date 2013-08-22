class AddIndexToCreatedAtPostReports < ActiveRecord::Migration
  def change
    add_index :post_reports, :created_at
  end
end
