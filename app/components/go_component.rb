# A ViewVomponent with Motion handling multiplayer interactive Go games
class GoComponent < ViewComponent::Base
  include Motion::Component

  map_motion :place

  def initialize(game:)
    @game = game
    @key = @game.key
    update_game_display
    stream_from "go:#{@key}", :next_turn
  end

  def place(event)
    index = event.target.data[:index].to_i
    pos = index_to_pos(index)

    return unless @game.legal_move?(pos)

    @game = @game.place(pos) # place returns self, the updated game
    ::Go::Game.update(key: @key, game: @game)
    broadcast_next_turn
  end

  private

  def broadcast_next_turn
    ActionCable.server.broadcast(game_channel, "move")
  end

  def game_channel
    "go:#{@key}"
  end

  def index_to_pos(index)
    ::Go::Pos.new((index / size), index.modulo(size))
  end

  def next_turn(_message)
    @game = ::Go::Game.find(key: @key)
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
