json.array!(@bathrooms) do |bathroom|
  json.(bathroom, :id, :name)
  json.stalls(bathroom.stalls) do |stall|
    json.extract! stall, :number, :state
  end
end
