class AddTeamToGameHistories < ActiveRecord::Migration
  def change
    add_column :game_histories, :team, :text, {
        :default => "",
    }
  end
end
