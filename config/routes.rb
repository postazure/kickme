Rails.application.routes.draw do
  root 'project_creators#index'

  resources :project_creators
  post 'project_creators/search' => 'project_creators#search'

  post 'registrations' => 'registrations#create'
  post 'login' => 'auth#create'
  post 'logout/:token' => 'auth#destroy'

  post 'user/follow' => 'users#follow'
  post 'user/unfollow' => 'users#unfollow'
  get 'user/project_creators' => 'users#project_creators'
end
