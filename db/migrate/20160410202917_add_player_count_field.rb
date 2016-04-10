class AddPlayerCountField < ActiveRecord::Migration
  def change
    add_column :rooms, :player_count, :integer, {
        :null => false,
        :default => 4,
    }
  end
end
