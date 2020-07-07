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
  end

  def click(event)
    amt = event.target.data[:amt] || 1
    @scored = amt.to_i
    player.score_points(scored)
  end

  def lucky_click(event)
    lvl = event.element.data[:luck].to_i

    @scored =
      if lvl == -1 # rotten luck
        6.times.map { luck_result }.min
      elsif lvl == 0 # bad luck
        3.times.map { luck_result }.min
      else
        lvl.times.map { luck_result }.max
      end.to_i

    player.score_points(scored)
  end

  def disconnected
    player.destroy
    game.destroy if game.clicker_players.count == 0

    ActionCable.server.broadcast(game.channel, nil)
  end

  private

  def luck_result
    case rand(1000)
    when 0..99 # 10%
      rand(-100..100)
    when 100..109 # 1%
      score * 7 # positive 7x current score
    when 110..119 # 1%
      (score * 7).abs * -1 # negative 7x current score
    when 120..129 # 1%
      -1 * score # back to zero!
    when 130..159 # 3%
      750
    when 160..164 # 0.5%
      7777 - score # hit all lucky 7s right on
    when 165..264 # 10%
      rand(90) - 10 # nice boost
    when 265..414 # 15%
      rand(400) - 50 # nicer boost
    when 415..564 # 15%
      rand(score) - rand(score * 0.3) # boost based on score
    else
      rand(50) - 10  # most of the time, a small, usually positive amount
    end
  end
end
