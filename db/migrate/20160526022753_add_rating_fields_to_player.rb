class AddRatingFieldsToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :rating_skill, :float
    add_column :players, :rating_confidence, :float
  end
end
