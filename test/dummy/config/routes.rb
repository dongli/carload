Rails.application.routes.draw do
  mount Carload::Engine => '/carload'
  resources :products
  resources :items
end
