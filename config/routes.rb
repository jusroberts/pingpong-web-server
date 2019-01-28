Rails.application.routes.draw do
  resources :season_stats
  resources :player_ratings
  get 'reports' => 'reports#index', as: :report_index
  get 'reports/leaderboard' => 'reports#leaderboard', as: :report_leaderboard
  get 'reports/player/:player_id' => 'reports#player', as: :player_report
  get 'reports/gameHistory/:game_id' => 'reports#game', as: :game_report
  get 'reports/historyTable/:player_id_1(/:player_id_2)' => 'reports#history', as: :history_table

  get 'players/:player_id/change_pin' => 'players#change_player_pin', as: :change_player_pin
  post 'players/:player_id/change_pin' => 'players#change_player_pin_post', as: :change_player_pin_post

  resources :rooms do
      resources :seasons do
        get 'leaderboard' => 'seasons#leaderboard', as: :leaderboard
      end
      get 'controller' => 'rooms#controller'
      get 'leaderboard' => 'rooms#leaderboard', as: :leaderboard
      get 'game/interstitial' => 'rooms#interstitial', as: :game_interstitial
      get 'game/new' => 'rooms#game_new', as: :game_new
      post 'game/new' => 'rooms#game_new_post', as: :game_new_post
      get 'game/' => 'rooms#game_view', as: :game_view
      get 'game/play' => 'rooms#game_play', as: :game_play
      post 'game/end' => 'rooms#game_end_post', as: :game_end
      get 'game/newfull' => 'rooms#game_newfull', as: :game_newfull
      post 'game/player_count' => 'rooms#game_player_count_post', as: :game_player_count_post
      get 'game/lookup_player' => 'players#lookup_player', as: :game_lookup_player
      get 'game/login_as/:player_id' => 'players#login_as_player', as: :game_login_as_player
      post 'game/login_as/:player_id' => 'players#login_as_player_post', as: :game_login_as_player_post

      post 'game/new/players/clear' => 'rooms#players_clear_post', as: :game_players_clear_post
      get 'game/new/players/create' => 'players#new', as: :game_new_player
      get 'game/new/players/create/cancel' => 'players#new_cancel', as: :game_new_player_cancel
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
  
  get '/api/rooms/:id/end' => 'rooms#end_game'
  get '/api/rooms/:id/team/:team/increment/:request_id' => 'rooms#increment_score', as: :increment_score
  get '/api/rooms/:id/team/:team/decrement/:request_id' => 'rooms#decrement_score', as: :decrement_score
  get '/api/rooms/:id/team/:team/taunt/:request_id' => 'rooms#taunt', as: :taunt
  get '/api/rooms/:id/status' => 'rooms#room_status', as: :room_status
  get '/api/rooms/:room_id/players/add' => 'players#handle_player_hash', as: :handle_player_hash
  get '/api/rooms/:room_id/players/predict' => 'players#predict_game', as: :predict_game
  get '/api/rooms/:room_id/players/optimize' => 'players#optimize_teams', as: :optimize_teams
  get '/api/rooms/:room_id/players/rank' => 'players#get_rank', as: :get_player_rank
  get '/api/rooms/:room_id/send_current_scores' => 'rooms#send_current_scores'
  get '/api/rooms/:id/activeseason' => 'rooms#active_season'
  get '/api/players' => 'players#list_all_players'


  resources :bathrooms do
    get 'stalls/:stall_id/:state' => 'bathrooms#set_stall_status'
    get 'stalls_stats/:days_ago' => 'bathrooms#stats', as: :stall_stats
  end
end
