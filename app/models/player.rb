class Player < ActiveRecord::Base
  has_many :room_players
  has_many :daily_stats
  has_many :weekly_stats
  has_many :season_stats
  has_many :rooms, through: :room_players
  has_many :player_ratings

  def get_latest_rating room_id
    room = Room.find(room_id)
    get_season_rating room.get_active_season.id
  end

  def get_season_rating season_id
    season = Season.find(season_id)
    rating = player_ratings.where(season_id: season.id).first
    if (rating == nil)
      rating = player_ratings.create(season_id: season.id)
    end
    rating
  end
end
