class AddStallStats < ActiveRecord::Migration
  def change
    create_table :stall_stats do |t|
      t.datetime :usage_start
      t.datetime :usage_end
      t.integer :stall_id

      t.timestamps
    end
  end
end
