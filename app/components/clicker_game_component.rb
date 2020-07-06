class ClickerGameComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :game, :player, :players

  delegate :channel, to: :game

  map_motion :click

  def initialize(game:, player:)
    @game = game
    @player = player

    stream_from game.channel, :refresh_scores

    refresh_scores
  end

  def click(event)
    amt = event.target.data[:amt] || 1
    player.score_points(amt.to_i)
    broadcast(game.channel, nil)
  end

  def disconnected
    player.destroy
    game.destroy if game.clicker_players.count == 0

    broadcast(game.channel, nil)
  end

  def refresh_scores
    @players = game.clicker_players.reload
  end
end
