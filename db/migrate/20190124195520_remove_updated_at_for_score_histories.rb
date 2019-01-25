class RemoveUpdatedAtForScoreHistories < ActiveRecord::Migration
  def change
    remove_column :score_histories, :updated_at
  end
end
