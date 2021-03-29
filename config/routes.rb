Rails.application.routes.draw do
  devise_for :users
  root to: "demos#index"

  get "/clock", to: "demos#clock", as: :clock_demo
  get "/calculator", to: "demos#calculator", as: :calculator_demo
  get "/form", to: "demos#form", as: :form_demo
  get "/modal", to: "demos#modal", as: :modal_demo
  get "/live-preview", to: "demos#live_preview", as: :live_preview

  resources :go, only: [:show, :create, :index] do
    post :join, on: :collection
  end

  resources :clicker_games, only: [:show, :create, :index] do
    post :join, on: :collection
  end
end
