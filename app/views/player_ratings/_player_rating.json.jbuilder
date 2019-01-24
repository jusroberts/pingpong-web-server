json.extract! player_rating, :id, :player_id, :season_id, :skill, :deviation, :created_at, :updated_at
json.url player_rating_url(player_rating, format: :json)
