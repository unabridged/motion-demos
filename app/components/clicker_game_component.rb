class ClickerGameComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :game, :player, :score

  delegate :key, :channel, to: :game

  map_motion :click

  def initialize(game:, player:)
    @game = game
    @player = player

    stream_from game.channel, :refresh_scores
  end

  def click(event)
    amt = event.target.data[:amt] || 1
    player.score_points(amt.to_i)
  end

  def refresh_scores
    game.reload
  end
end
