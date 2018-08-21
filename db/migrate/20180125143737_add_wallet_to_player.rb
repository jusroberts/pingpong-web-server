class AddWalletToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :wallet, :string
  end
end
