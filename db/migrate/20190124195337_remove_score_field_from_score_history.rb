class RemoveScoreFieldFromScoreHistory < ActiveRecord::Migration
  def change
    remove_column :score_histories, :score_change
  end
end
