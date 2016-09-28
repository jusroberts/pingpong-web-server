class ChangeRatingConfidenceFieldName < ActiveRecord::Migration
  def change
    rename_column :players, :rating_confidence, :rating_deviation
  end
end
