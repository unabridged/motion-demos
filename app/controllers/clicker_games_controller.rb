class ClickerGamesController < ApplicationController
  before_action :enforce_valid_game_key, only: [:show, :join]

  helper_method :key

  def index
  end

  def show
  end

  def create
    key = SecureRandom.hex(5)

    redirect_to clicker_game_path(id: key)
  end

  def join
    redirect_to clicker_game_path(id: key)
  end

  private

  def key
    @key ||= params[:id]
  end

  def enforce_valid_game_key
    unless key =~ /\A[A-Za-z\d]{10}\z/
      redirect_to clicker_games_path, error: "Invalid key" and return false
    end
  end
end
