Rails.application.routes.draw do
  root to: "demos#index"

  get "/calculator", to: "demos#calculator", as: :calculator_demo
  get "/form", to: "demos#form", as: :form_demo
end
