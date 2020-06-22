class ClickerGame < ViewComponent::Base
  include Motion::Component

  attr_reader :key, :player, :score, :game

  map_motion :click

  PLAYERS = %i[
    dragon fly pigeon gull eagle robin flea mosquito airplane
    rocket flamingo raptor falcon owl squirrel dino zebra
    unicorn puma giraffe pikachu chair glasses sorcerer wizard
    knight squire cauldron sparrow finch penguin otter]

  def initialize(key:)
    @key = key
    @player = PLAYERS.sample.to_s
    @game = { player => 0 }

    stream_from game_channel, :player_click

    track_score
  end

  def click(event)
    amt = event.target.data[:amt] || 1
    game[player] += amt.to_i

    track_score
  end

  def player_click(message)
    msg = ActiveSupport::JSON.decode(message)

    game[msg["player"]] = msg["score"].to_i
  end

  private

  def game_channel
    "clicker:#{key}"
  end

  def track_score
    @score = game[player]

    ActionCable.server.broadcast(game_channel, {
      player: player,
      score: score,
    })
  end
end
