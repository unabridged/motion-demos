class AddStarredAndTrashed < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :starred_by_to, :datetime
    add_column :messages, :starred_by_from, :datetime
    add_column :messages, :deleted_by_to, :datetime
    add_column :messages, :deleted_by_from, :datetime
  end
end
