class ClickerGamesController < ApplicationController
  layout "clicker"

  def create
    game = ClickerGame.create

    redirect_to clicker_game_path(game)
  end

  def join
    redirect_to clicker_game_path(id: key)
  end

  def show
    game = ClickerGame.find_by(key: key)
    redirect_to(clicker_games_path) && return unless game

    player = game.clicker_players.create

    render locals: {game: game, player: player}
  end

  def index
    recent_games = ClickerGame
      .order(:updated_at)
      .where("updated_at > ?", 5.minutes.ago)
      .sample(5)

    render locals: {recent_games: recent_games}
  end

  private

  def key
    @key ||= params[:id]
  end
end
