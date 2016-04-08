Rails.application.routes.draw do
  resources :rooms do

      get 'game/new' => 'rooms#game_new', as: :game_new
      post 'game/new' => 'rooms#game_new_post', as: :game_new_post
      get 'game/' => 'rooms#game_view', as: :game_view
      get 'game/play' => 'rooms#game_play', as: :game_play
      post 'game/end' => 'rooms#game_end_post', as: :game_end
      get 'game/newfull' => 'rooms#game_newfull', as: :game_newfull


      get 'game/new/players/create' => 'players#new', as: :game_new_player
      post 'game/new/players/create' => 'players#new_post', as: :game_new_player_post
      get 'game/new/players/:player_id' => 'players#confirm', as: :game_player_confirm
      delete 'game/new/players/:player_id' => 'players#delete', as: :game_player_delete
      get 'game/new/players/:player_id/attach_image' => 'players#attach_image', as: :game_player_attach_image
      post 'game/new/players/:player_id/attach_image' => 'players#attach_image_post', as: :game_player_attach_image_post
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'rooms#index'

  get '/api/rooms/:id/team/:team/increment' => 'rooms#increment_score', as: :increment_score
  get '/api/rooms/:room_id/players/add' => 'players#handle_player_hash', as: :handle_player_hash

end
