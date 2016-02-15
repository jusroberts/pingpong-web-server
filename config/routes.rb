Rails.application.routes.draw do
  resources :rooms

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'rooms#index'

  get 'rooms/:id/team/:team/increment' => 'rooms#increment_score', as: :increment_score

end
