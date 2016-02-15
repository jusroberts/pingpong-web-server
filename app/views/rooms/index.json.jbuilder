json.array!(@rooms) do |room|
  json.extract! room, :id, :client_token, :team_a_score, :team_b_score, :name
  json.url room_url(room, format: :json)
end
