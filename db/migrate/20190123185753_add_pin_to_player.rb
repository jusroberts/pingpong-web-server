class AddPinToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :pin, :string, default: "0000", null: false
  end
end
