# A ViewVomponent with Motion handling multiplayer interactive Go games
class GoComponent < ViewComponent::Base
  include Motion::Component

  after_connect :connected
  after_disconnect :remove_player

  map_motion :place

  def initialize(game:)
    puts "component initialize: #{game}"
    @game = game
    puts "component initialize instance var: #{@game}"
    @key = game.key
    update_game_display
    stream_from "go:#{@key}", :next_turn
  end

  def place(event)
    index = event.target.data[:index].to_i
    pos = index_to_pos(index)

    return unless @game.legal_move?(pos)

    @game = @game.place(pos) # place returns self, the updated game
    update_game
    broadcast_next_turn
  end

  def remove_player
    @game.players -= 1

    if @game.players.zero?
      ::Go::Game.delete(key: @key)
    else
      update_game
    end
  end

  private

  def broadcast_next_turn
    ActionCable.server.broadcast(game_channel, "move")
  end

  def connected
    # puts "component connected before find: #{@game}"
    # @game = ::Go::Game.find(key: @key)
    puts "component connected after find: #{@game}"
    @game.players += 1
    update_game
    puts "component connected after update: #{@game}"
    update_game_display
  end

  def game_channel
    "go:#{@key}"
  end

  def index_to_pos(index)
    ::Go::Pos.new((index / size), index.modulo(size))
  end

  def next_turn(_message = nil)
    @game = ::Go::Game.find(key: @key)
    update_game_display
  end

  def size
    @game.size
  end

  def update_game
    ::Go::Game.update(key: @key, game: @game)
  end

  def update_game_display
    @board = @game.display
    @current = @game.current
    @captures = @game.captures
  end
end
