class AddArchivedFieldToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :is_archived, :boolean, :default => false
  end
end
