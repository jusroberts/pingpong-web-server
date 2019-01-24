class AddSeasonToWeeklyStats < ActiveRecord::Migration
  def change
    add_reference :weekly_stats, :season, index: true, foreign_key: true
  end
end
