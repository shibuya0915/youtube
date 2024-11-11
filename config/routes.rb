Rails.application.routes.draw do
  resources :videos

  root 'videos#index'
end
