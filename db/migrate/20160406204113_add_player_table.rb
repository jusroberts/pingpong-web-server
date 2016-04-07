class AddPlayerTable < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :rfid_hash
      t.string :name
      t.string :image_url
      t.timestamps
    end
    add_index :players, :rfid_hash
  end
end
