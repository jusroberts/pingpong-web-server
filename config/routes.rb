Rails.application.routes.draw do
  resources :rooms

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'rooms#index'

  get '/api/rooms/:id/team/:team/increment' => 'rooms#increment_score', as: :increment_score

  get '/rooms/:id/game/new' => 'rooms#game_new', as: :game_new
  post '/rooms/:id/game/new' => 'rooms#game_new_post', as: :game_new_post
  get '/rooms/:id/game/' => 'rooms#game_view', as: :game_view
  get '/rooms/:id/game/play' => 'rooms#game_play', as: :game_play
  post '/rooms/:id/game/end' => 'rooms#game_end', as: :game_end
end
