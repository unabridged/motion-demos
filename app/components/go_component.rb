class GoComponent < ViewComponent::Base
  include Motion::Component

  map_motion :place
  map_motion :reset

  def initialize(key:)
    @key = key
    @game = GoGame.find(key: key) || GoGame.new(key: key)
    puts "component game #{@game}"
    @board = @game.display
    @current = @game.current
    @captures = @game.captures

    stream_from "go:#{@key}", :player_move
  end

  def place(event)
    index = event.target.data[:index].to_i
    pos = GoGame::Pos.new((index / 9), index.modulo(9))

    if @game.legal_move?(pos)
      @game.place(pos)
      @game.next_player
      GoGame.update(key: @key, game: @game)
    end
  end

  def reset
    @game = GoGame.new
    @board = @game.display
    @current = @game.current
    @captures = @game.captures
    broadcast_board
  end

  private

  def player_move(message)
    @game = GoGame.find(key: @key)
    @current = message["current"]
    @captures = message["captures"]
    @board = message["board"]
  end
end
