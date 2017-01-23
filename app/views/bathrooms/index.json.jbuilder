json.array!(@bathrooms) do |bathroom|
  json.extract! bathroom, :id, :name, :token
  json.url bathroom_url(bathroom, format: :json)
end
