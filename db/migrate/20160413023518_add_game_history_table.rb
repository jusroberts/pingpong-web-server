class AddGameHistoryTable < ActiveRecord::Migration
  def change
    create_table :game_histories do |t|
      t.belongs_to :room, index: true
      t.belongs_to :player, index: true
      t.integer :game_id
      t.string :game_session_id, length: 16
      t.integer :player_count
      t.integer :player_team_score
      t.integer :opponent_team_score
      t.boolean :win
      t.timestamps
    end
    # For API calls to look up how many games have been played during the current session
    add_index :game_histories, [:game_id, :game_session_id]
    # General stat lookup for a player
    add_index :game_histories, [:player_id, :win, :player_count]

    add_column :rooms, :game_session_id, :string
  end
end
