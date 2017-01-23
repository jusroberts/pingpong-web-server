class CreateStalls < ActiveRecord::Migration
  def change
    create_table :stalls do |t|
      t.integer :bathroom_id
      t.boolean :state
      t.integer :number

      t.timestamps
    end
  end
end
