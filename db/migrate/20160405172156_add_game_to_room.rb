class AddGameToRoom < ActiveRecord::Migration
  def change
    add_column :rooms, :game, :boolean
  end
end
