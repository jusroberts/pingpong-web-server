class ChangeRatingConfidenceFieldName < ActiveRecord::Migration
  def change
    rename_column :players, :rating_deviation, :rating_deviation
  end
end
