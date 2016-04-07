class PlayersController < ApplicationController

  before_action :set_player, only: [:confirm, :delete]
  before_action :set_room_id

  def new
  end

  def new_post
  end

  def attach_image
  end

  def attach_image_post
  end

  def confirm
  end

  def delete
    #Player.find(params[:player_id]).delete
  end

  private

  def set_player
    #@player = Player.find(params[:player_id])
  end

  def set_room_id
    @id = Room.find(params[:room_id]).id
  end

end
