class AddSeasonToDailyStats < ActiveRecord::Migration
  def change
    add_reference :daily_stats, :season, index: true, foreign_key: true
  end
end
