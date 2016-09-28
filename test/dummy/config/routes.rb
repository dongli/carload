Rails.application.routes.draw do
  resources :items
  mount Carload::Engine => "/carload"
end
