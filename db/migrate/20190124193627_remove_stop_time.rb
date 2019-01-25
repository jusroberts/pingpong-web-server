class RemoveStopTime < ActiveRecord::Migration
  def change
    remove_column :rooms, :end_time
  end
end
