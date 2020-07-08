# frozen_string_literal: true

# A ViewVomponent with Motion handling multiplayer interactive Go games
class GoComponent < ViewComponent::Base
  include Motion::Component

  map_motion :place

  def initialize(key:)
    @key = key
    @game = GoGame.find(key: key) || GoGame.new(key: key)
    update_game_display
    stream_from "go:#{@key}", :player_move
  end

  def place(event)
    index = event.target.data[:index].to_i
    pos = index_to_pos(index)

    return unless @game.legal_move?(pos)

    @game.place(pos)
    @game.next_player
    GoGame.update(key: @key, game: @game)
  end

  private

  def index_to_pos(index)
    GoGame::Pos.new((index / size), index.modulo(size))
  end

  def player_move(_message)
    @game = GoGame.find(key: @key)
    update_game_display
  end

  def size
    @game.size
  end

  def update_game_display
    @board = @game.display
    @current = @game.current
    @captures = @game.captures
  end
end
