class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :client_token
      t.integer :team_a_score
      t.integer :team_b_score
      t.string :name

      t.timestamps
    end
  end
end
