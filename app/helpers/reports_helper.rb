module ReportsHelper
  def player_name player_id
    if !cached_names[player_id]
      cached_names[player_id] = Player.find(player_id).name rescue "ERROR"
    end
    cached_names[player_id]
  end

  def cached_names
    @cached_names ||= {}
  end
end
