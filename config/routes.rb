Rails.application.routes.draw do
  root to: "demos#index"

  get "/calculator", to: "demos#calculator", as: :calculator_demo
end
