class CreateStallStats < ActiveRecord::Migration
  def change
    create_table :stall_stats do |t|

      t.timestamps
    end
  end
end
