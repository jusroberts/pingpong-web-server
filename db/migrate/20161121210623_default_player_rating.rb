class DefaultPlayerRating < ActiveRecord::Migration
  def change
    change_column_default(:players, :rating_skill, 25.0)
    change_column_default(:players, :rating_deviation, 8.333333333333334)
  end
end
