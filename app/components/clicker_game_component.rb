class ClickerGameComponent < ViewComponent::Base
  include Motion::Component
  include ClickerGameHelper

  attr_reader :game, :player, :players, :scored

  delegate :channel, to: :game
  delegate :score, to: :player

  map_motion :click
  map_motion :lucky_click

  def initialize(game:, player:)
    @game = game
    @player = player

    stream_from game.channel, :refresh_scores

    refresh_scores
  end

  def click(event)
    amt = event.target.data[:amt] || 1
    @scored = amt.to_i
    player.score_points(scored)
    broadcast(game.channel, nil)
  end

  def lucky_click
    @scored =
      case rand(100)
      when 0..4
        100
      when 5..9
        -100
      else
        rand(40) - 10
      end

    player.score_points(scored)
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
