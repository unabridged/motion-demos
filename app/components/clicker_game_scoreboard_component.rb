class ClickerGameScoreboardComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :game, :player, :players

  def initialize(game:, player:)
    @game = game
    @player = player

    stream_from game.channel, :refresh_scores

    refresh_scores
  end

  def refresh_scores
    @players = game.clicker_players.reload
  end
end
