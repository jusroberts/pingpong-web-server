class AddPlayerRoomJoinTable < ActiveRecord::Migration
  def change
    create_table :rooms_players do |t|
      t.belongs_to :room, index: true
      t.belongs_to :player, index: true
      t.string :team, :limit => 5
    end
  end
end
