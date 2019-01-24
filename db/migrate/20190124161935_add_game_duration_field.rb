class AddGameDurationField < ActiveRecord::Migration
  def change
    add_column :game_histories, :duration_seconds, :integer, {
        :default => 0,
    }
  end
end
