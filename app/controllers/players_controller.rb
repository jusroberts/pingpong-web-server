class PlayersController < ApplicationController

  before

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

end
