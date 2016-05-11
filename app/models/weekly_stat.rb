class WeeklyStat < ActiveRecord::Base
  belongs_to :player
  belongs_to :most_defeated_player, class_name: 'Player', foreign_key: 'most_defeated_player_id'
  belongs_to :most_defeated_by_player, class_name: 'Player', foreign_key: 'most_defeated_by_player_id'
end
