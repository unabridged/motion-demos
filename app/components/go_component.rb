class GoComponent < ViewComponent::Base
  include Motion::Component

  map_motion :place
  map_motion :reset

  @@game = GoGame.new

  def initialize
    @board = @@game.display
    @current = @@game.current
    @captures = @@game.captures

    stream_from game_channel, :player_move

    broadcast_board
  end

  def place(event)
    index = event.target.data[:index].to_i
    pos = GoGame::Pos.new((index / 9), index.modulo(9))

    if @@game.legal_move?(pos)
      make_move(pos)
      broadcast_board
    end
  end

  def player_move(message)
    @current = message["current"]
    @captures = message["captures"]
    @board = message["board"]
  end

  def reset
    @@game = GoGame.new
    @board = @@game.display
    @current = @@game.current
    @captures = @@game.captures
    broadcast_board
  end

  private

  def game_channel
    "go:foo"
  end

  def make_move(pos)
    @@game.place(pos)
    @captures = @@game.captures
    @board = @@game.display

    @@game.next_player
    @current = @@game.current
  end

  def broadcast_board
    ActionCable.server.broadcast(game_channel, {
      board: @board,
      captures: @captures,
      current: @current,
    })
  end
end
