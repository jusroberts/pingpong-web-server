class AddStreakHandling < ActiveRecord::Migration
  def change
    add_column :rooms, :streak, :integer, {
        :default => 0,
    }
    add_column :rooms, :streak_history, :text, {
        :default => "",
    }
  end
end
