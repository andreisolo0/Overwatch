Rails.application.routes.draw do
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
end
