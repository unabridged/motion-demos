module Go
  # this class represents everything needed to build a square Go board,
  # track the state of the game, and possibly produce a game record based
  # on the stones placed on the board.
  class Game
    # TODO: replace with DB storage of games
    @active_games = {}

    def self.create(size: 9)
      key = SecureRandom.hex(5)
      game = new(size: size, key: key)
      update(key: key, game: game)
      game
    end

    def self.find(key:)
      @active_games[key]
    end

    def self.update(key:, game:)
      @active_games[key] = game
    end

    def self.delete(key:)
      puts "deleting game #{key}"
      @active_games.delete(key)
    end

    # some of these could be removed, i was using the readers to test with
    attr_reader :board, :current, :captures, :groups, :key, :move, :size
    attr_accessor :players

    def initialize(size: 9, key:)
      @players = 0
      @size = size
      @move = 1 # TODO: track move number
      @board = (1..size).map { |_| (1..size).map { |_| nil } }
      @current = :black
      @captures = {"black" => 0, "white" => 0}
      @groups = {black: [], white: []}

      @key = key
      Game.update(key: key, game: self)
    end

    # flattens the board and only includes stone color for the view
    def display
      board.flatten.map { |stone| stone&.color }
    end

    def legal_move?(pos)
      return true unless occupied?(pos)
    end

    # TODO: this could be private, currently tested as a public method
    def liberties(group)
      group
        .map { |pos| pos.neighbors_in_bounds(size) }.flatten.uniq
        .count { |pos| !occupied?(pos) }
    end

    # TODO: this could be private, currently tested as a public method
    def next_player
      @current = current == :black ? :white : :black
    end

    # TODO: add illegal moves, including Ko rule
    def place(pos)
      @board[pos.i][pos.j] = Stone.new(current, pos, move)
      UpdateGroups.call(game: self, pos: pos)
      opponent = current == :black ? :white : :black
      capture(opponent)
      capture(current)
      next_player
      self
    end

    private

    def capture(color)
      captured = @groups[color].select { |grp| liberties(grp).zero? }

      captured.each do |grp|
        grp.each { |pos| @board[pos.i][pos.j] = nil }
        @captures[color.to_s] += grp.length
        @groups[color].delete(grp) # TODO: deleting groups makes it hard to undo, or go back in time
      end
    end

    def occupied?(pos)
      board[pos.i][pos.j]
    end
  end
end
