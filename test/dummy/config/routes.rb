Rails.application.routes.draw do
  devise_for :users
  mount Carload::Engine => '/carload'
end
