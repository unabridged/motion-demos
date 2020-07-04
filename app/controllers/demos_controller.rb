class DemosController < ApplicationController
  layout "dashboard", only: [:dashboard]
  def dashboard
    sign_in User.first
  end
end
