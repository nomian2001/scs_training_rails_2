Rails.application.routes.draw do
  root 'containers#index'
  
  resources :containers
  resources :items
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
