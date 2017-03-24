Rails.application.routes.draw do
  get 'reports' => 'reports#index', as: :report_index
  get 'reports/leaderboard' => 'reports#leaderboard', as: :report_leaderboard
  get 'reports/player/:player_id' => 'reports#player', as: :player_report
  get 'reports/historyTable/:player_id_1(/:player_id_2)' => 'reports#history', as: :history_table

  resources :rooms do
      get 'controller' => 'rooms#controller'
      get 'game/interstitial' => 'rooms#interstitial', as: :game_interstitial
      get 'game/new' => 'rooms#game_new', as: :game_new
      post 'game/new' => 'rooms#game_new_post', as: :game_new_post
      get 'game/' => 'rooms#game_view', as: :game_view
      get 'game/play' => 'rooms#game_play', as: :game_play
      post 'game/end' => 'rooms#game_end_post', as: :game_end
      get 'game/newfull' => 'rooms#game_newfull', as: :game_newfull
      post 'game/player_count' => 'rooms#game_player_count_post', as: :game_player_count_post

      post 'game/new/players/clear' => 'rooms#players_clear_post', as: :game_players_clear_post
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
  root 'rooms#home'

  get '/api/rooms/:id/team/:team/increment' => 'rooms#increment_score', as: :increment_score
  get '/api/rooms/:id/team/:team/decrement' => 'rooms#decrement_score', as: :decrement_score
  get '/api/rooms/:id/status' => 'rooms#room_status', as: :room_status
  get '/api/rooms/:room_id/players/add' => 'players#handle_player_hash', as: :handle_player_hash
  get '/api/rooms/:room_id/players/predict' => 'players#predict_game', as: :predict_game
  get '/api/rooms/:room_id/players/optimize' => 'players#optimize_teams', as: :optimize_teams
  get '/api/rooms/:room_id/players/rank' => 'players#get_rank', as: :get_player_rank
  get '/api/rooms/:room_id/send_current_scores' => 'rooms#send_current_scores'


  resources :bathrooms do
    get 'stalls/:stall_id/:state' => 'bathrooms#set_stall_status'
    get 'stalls_stats/:days_ago' => 'bathrooms#stats', as: :stall_stats
  end
end
