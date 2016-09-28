Carload::Engine.routes.draw do
  root 'dashboard#index'

  get    'dashboard(/:model)'      => 'dashboard#index',   as: :dashboard_index
  match  'dashboard/:model/search' => 'dashboard#search',  as: :dashboard_search, via: [:get, :post]
  get    'dashboard/:model/new'    => 'dashboard#new',     as: :dashboard_new
  get    'dashboard/:model/:id'    => 'dashboard#edit',    as: :dashboard_edit
  post   'dashboard/:model'        => 'dashboard#create'
  patch  'dashboard/:model/:id'    => 'dashboard#update'
  put    'dashboard/:model/:id'    => 'dashboard#update'
  delete 'dashboard/:model/:id'    => 'dashboard#destroy', as: :dashboard_delete
  get    'dashboard/error'         => 'dashboard#error',   as: :dashboard_error
end
