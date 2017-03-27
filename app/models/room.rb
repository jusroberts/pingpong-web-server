class Room < ActiveRecord::Base
  has_many :room_players, dependent: :destroy
  has_many :players, through: :room_players

  NO_TEAM_SERVING = 0
  TEAM_A_SERVING = 1
  TEAM_B_SERVING = 2
end
