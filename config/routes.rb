Rails.application.routes.draw do
  devise_for :users
  root to: "demos#index"

  get "/clock", to: "demos#clock", as: :clock_demo
  get "/calculator", to: "demos#calculator", as: :calculator_demo
  get "/form", to: "demos#form", as: :form_demo
  get "/lists", to: "demos#lists", as: :lists_demo

  resources :clicker_games, only: [:show, :create, :index] do
    post :join, on: :collection
  end
end
