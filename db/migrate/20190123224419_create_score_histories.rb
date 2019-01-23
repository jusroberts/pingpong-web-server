class CreateScoreHistories < ActiveRecord::Migration
  def change
    create_table :score_histories do |t|
      t.integer :game_id
      t.string :team
      t.integer :score_change
      t.timestamps null: false
    end
  end
end
