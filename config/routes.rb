Rails.application.routes.draw do
  resources :host_items, only: [:create, :destroy, :update]
  post 'schedule_collector_job', to: 'host_items#schedule_collector_job'
  resources :articles
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'pages#home'
  get 'about' , to: 'pages#about'
  get 'home'  , to: 'pages#home'
  get 'signup' , to: 'users#new'
  get 'new_host' , to: 'hosts#new'
  #post 'users', to: 'users#create'
  resources :users, except: [:new]
  resources :hosts, except: [:new]
  get 'login' , to: 'sessions#new'
  post 'login' , to: 'sessions#create'
  delete 'logout' , to: 'sessions#destroy'
  get 'forbidden' , to: 'pages#forbidden'
  #resources :actions, only: %i[index]
  get 'test_connection', to: 'remote_actions#test_connection'
  #post 'apply_remote_action', to: 'remote_actions#apply_remote_action'
  get 'apply_remote_action', to: 'remote_actions#apply_remote_action'
  get 'unassign_items', to: 'items#unassign_items'
  get 'triggers', to: 'host_items#triggers'
  resources :items
  resources :remote_actions
  resources :active_alerts
end
