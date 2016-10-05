Rails.application.routes.draw do
  devise_for :users
  mount Carload::Engine => '/carload'
  resources :products
  resources :items
  resources :packages
end
