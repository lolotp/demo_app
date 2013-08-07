class CreateUserViewablePosts < ActiveRecord::Migration
  def change
    create_table :user_viewable_posts do |t|

      t.timestamps
    end
  end
end
