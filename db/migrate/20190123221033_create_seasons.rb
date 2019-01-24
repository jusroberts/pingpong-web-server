class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.string :name
      t.belongs_to :room, index: true, foreign_key: true
      t.boolean :active

      t.timestamps null: false
    end
  end
end
