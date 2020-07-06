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
    player = game.clicker_players.create

    render :show, locals: { game: game, player: player }
  end

  private

  def key
    @key ||= params[:id]
  end
end
