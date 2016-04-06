class ApiController < WebsocketRails::BaseController
  def initialize_session

  end


  def test
    new_message = {:message => 'this is a message'}
    send_message :event_name, new_message
  end

  # /rooms/1/team/a/increment
  def increment_score
    team = params[:team].downcase
    raise("invalid team") if params[:team].downcase != 'a' && params[:team].downcase != 'b'
    if should_reset?
      @room.update_attributes(team_a_score: 0, team_b_score: 0)
    else
      current_score = @room.method("team_#{team}_score".to_sym).call()
      @room.update_attribute("team_#{team}_score", current_score + 1)
    end
    render nothing: true
  end
end
