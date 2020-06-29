class RestorationGameController < ApplicationController

  def initialize
    session[:selected] = 0
  end
end