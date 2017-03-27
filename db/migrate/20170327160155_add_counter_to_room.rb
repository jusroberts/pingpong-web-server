class AddCounterToRoom < ActiveRecord::Migration
  def change
    add_column :rooms, :last_request_id, :integer
    add_column :rooms, :initial_serving_team, :integer, default: 0
  end
end
