Carload::Engine.routes.draw do
  root 'dashboard#index'

  get    'dashboard/config'        => 'dashboard#show_config',  as: :dashboard_show_config
  get    'dashboard(/:model)'      => 'dashboard#index',   as: :dashboard_index
  match  'dashboard/:model/search' => 'dashboard#search',  as: :dashboard_search, via: [:get, :post]
  get    'dashboard/:model/new'    => 'dashboard#new',     as: :dashboard_new
  get    'dashboard/:model/:id'    => 'dashboard#edit',    as: :dashboard_edit
  post   'dashboard/:model'        => 'dashboard#create'
  patch  'dashboard/:model/:id'    => 'dashboard#update'
  put    'dashboard/:model/:id'    => 'dashboard#update'
  delete 'dashboard/:model/:id'    => 'dashboard#destroy', as: :dashboard_delete

  [:dashboard, :unauthorized].each do |error_type|
    get "errors/#{error_type}" => "errors##{error_type}_error", as: "#{error_type}_error"
  end
end
