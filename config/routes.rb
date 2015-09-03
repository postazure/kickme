Rails.application.routes.draw do
  root 'project_creators#index'

  resources :project_creators
  post 'project_creators/search' => 'project_creators#search'

  post 'registrations' => 'registrations#create'
  post 'login' => 'auth#create'
  delete 'logout/:token' => 'auth#destroy'

  post 'user/:token/follow' => 'users#follow'
  post 'user/:token/unfollow' => 'users#unfollow'
  get 'users/:token/project_creators' => 'users#project_creators'
end
