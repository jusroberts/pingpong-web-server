class RoomPlayer < ActiveRecord::Base
  belongs_to :room
  belongs_to :player

  # player_number is always the team-specific number, so for doubles,
  # team A has players 1 and 2 and team B has their own 1 and 2
end
