class CreatePlayerRatings < ActiveRecord::Migration
  def change
    create_table :player_ratings do |t|
      t.integer :player_id
      t.integer :season_id
      t.float :skill, default: 25.0
      t.float :deviation, default: 8.333333333333334

      t.timestamps null: false
    end
  end
end
