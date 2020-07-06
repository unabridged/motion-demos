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
  end

  def lucky_click
    @scored = luck_result

    player.score_points(scored)
  end

  def disconnected
    player.destroy
    game.destroy if game.clicker_players.count == 0

    broadcast(game.channel, nil)
  end

  def refresh_scores
    @players = game.clicker_players.reload
  end

  private

  def luck_result
    case rand(1000)
    when 0..49 # 5%
      100
    when 50..99 # 5%
      -100
    when 100..109 # 1%
      score * 100
    when 110..119 # 1%
      score * -100
    when 120..129 # 1%
      -1 * score # back to zero!
    when 130..159 # 3%
      750
    when 160..164 # 0.5%
      7777 - score # hit all lucky 7s right on
    else
      rand(40) - 10  # most of the time, a small, usually positive amount
    end
  end
end
