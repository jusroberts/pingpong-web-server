class AddPlayerRoomJoinTable < ActiveRecord::Migration
  def change
    create_table :room_players do |t|
      t.belongs_to :room, index: true
      t.belongs_to :player, index: true
      t.string :team, :limit => 5
      t.integer :player_number
    end
  end
end
