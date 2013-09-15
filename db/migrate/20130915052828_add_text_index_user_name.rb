class AddTextIndexUserName < ActiveRecord::Migration
  def up
    execute "CREATE INDEX users_name_text_index ON users USING gin(to_tsvector('english', name))"
  end

  def down
    execute "DROP INDEX users_name_text_index"
  end
end
