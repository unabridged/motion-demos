class ClickerPlayer < ApplicationRecord
  PLAYERS = %w[
    dragon fly pigeon gull eagle robin flea mosquito airplane
    rocket flamingo raptor falcon owl squirrel dino zebra
    unicorn puma giraffe pikachu chair glasses sorcerer wizard
    knight squire cauldron sparrow finch penguin otter hacker
    antelope kelp commander general daisy pup limo]

  belongs_to :clicker_game, touch: true

  before_validation :assign_name, on: :create
  after_save :broadcast_game_change

  def score_points(num)
    self.score += num
    save
  end

  private

  def assign_name
    self.name ||= (PLAYERS - clicker_game.clicker_players.pluck(:name)).sample
  end

  def broadcast_game_change
    ActionCable.server.broadcast(clicker_game.channel, nil)
  end
end
