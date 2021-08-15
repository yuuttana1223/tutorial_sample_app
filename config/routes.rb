Rails.application.routes.draw do
  get "password_resets/new"

  get "password_resets/edit"

  root "static_pages#home"
  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
  get "/contact", to: "static_pages#contact"
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :users
  # PATCHリクエストとupdateアクションになるべき
  # リンクをクリックすれば、それはブラウザで普通にクリックしたときと同じ
  # http://www.example.com/account_activations/q5lt38hQDc_959PVoo6b7A/edit が生成
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
end
