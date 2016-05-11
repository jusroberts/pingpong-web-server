class Player < ActiveRecord::Base
  has_many :room_players
  has_many :daily_stats
  has_many :weekly_stats
  has_many :rooms, through: :room_players
end
