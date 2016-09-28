Rails.application.routes.draw do
  resources :products
  resources :items
  mount Carload::Engine => '/carload'
end
