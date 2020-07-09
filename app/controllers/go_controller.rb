class GoController < ApplicationController
  before_action :enforce_valid_game_key, only: [:show, :join]

  helper_method :key

  layout "go"

  def create
    game = Go::Game.create

    # TODO: Games persist in memory for 1 hour, remove when shift to DB persistence
    GoGameCleanupJob.set(wait: 1.hour).perform_later(key: game.key)

    redirect_to go_path(id: game.key)
  end

  def join
    redirect_to go_path(id: key)
  end

  def show
    game = Go::Game.find(key: key) || nil

    unless game
      redirect_to go_index_path, notice: "game expired" and return
    end

    render locals: {game: game}
  end

  private

  def key
    @key ||= params[:id]
  end

  def enforce_valid_game_key
    unless /\A[A-Za-z\d]{10}\z/.match? key
      redirect_to(go_index_path, error: "Invalid key") and return
    end
  end
end
