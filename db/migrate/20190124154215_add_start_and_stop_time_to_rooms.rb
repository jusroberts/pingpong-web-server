class AddStartAndStopTimeToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :start_time, :datetime, null: true
    add_column :rooms, :end_time, :datetime, null: true
  end
end
