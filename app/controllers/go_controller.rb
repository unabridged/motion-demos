class GoController < ApplicationController
  before_action :enforce_valid_game_key, only: [:show, :join]

  helper_method :key

  layout "go"

  def create
    game = Go::Game.create

    redirect_to go_path(id: game.key)
  end

  def join
    redirect_to go_path(id: key)
  end

  def show
    game = Go::Game.find(key: key) || nil

    unless game
      # rubocop:disable Style/AndOr
      redirect_to go_index_path, notice: "game expired" and return
      # rubocop:enable Style/AndOr
    end

    render locals: {game: game}
  end

  private

  def key
    @key ||= params[:id]
  end

  def enforce_valid_game_key
    unless /\A[A-Za-z\d]{10}\z/.match? key
      # rubocop:disable Style/AndOr
      redirect_to(go_index_path, error: "Invalid key") and return
      # rubocop:enable Style/AndOr
    end
  end
end
