class GameHistory < ActiveRecord::Base
  belongs_to :room
  belongs_to :player
end
