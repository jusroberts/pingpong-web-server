class Player < ActiveRecord::Base
  has_many :room_players
  has_many :rooms, through: :room_players
end
