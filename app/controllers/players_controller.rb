class PlayersController < ApplicationController

  before_action :set_player, only: [:confirm, :delete, :attach_image, :attach_image_post]
  before_action :set_room_id

  def new
  end

  def new_post
    player = Player.new(name: params[:name])
    player.save
    redirect_to room_game_player_attach_image_path(room_id: @id, player_id: player.id)
  end

  def attach_image
  end

  def attach_image_post
    image = params[:capture][:image]
    hash = Cloudinary::Uploader.upload(image)
    image_url = hash['secure_url']
    @player.update_attribute(:image_url, image_url)
    redirect_to room_game_new_path(room_id: @id, p1: @player.id)
  end

  def confirm
  end

  def delete
    #Player.find(params[:player_id]).delete
  end

  private

  def set_player
    @player = Player.find(params[:player_id])
  end

  def set_room_id
    @id = Room.find(params[:room_id]).id
  end

end
