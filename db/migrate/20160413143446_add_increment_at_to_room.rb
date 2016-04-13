class AddIncrementAtToRoom < ActiveRecord::Migration
  def change
    add_column :rooms, :increment_at, :datetime
  end
end
