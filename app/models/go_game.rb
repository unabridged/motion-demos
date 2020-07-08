# this class represents everything needed to build a square Go board,
# track the state of the game, and possibly produce a game record based
# on the stones placed on the board.
class GoGame
  # a position on the board, where top left is 0,0
  # represents indexes into the matrix representing the board
  # i is the row and j is the column in the matrix
  Pos = Struct.new(:i, :j) {
    def +(other)
      Pos.new(other.i + i, other.j + j)
    end

    def neighbors
      [Pos.new(1, 0), Pos.new(0, 1), Pos.new(-1, 0), Pos.new(0, -1)].map { |dir| self + dir }
    end
  }

  # this represents a stone placed on a board at a given position
  # as well as the move number sequence of when it was played
  # color : :black | :white
  # pos : Pos
  # num : Integer
  Stone = Struct.new(:color, :pos, :num)

  # TODO: replace with DB storage of games
  @active_games = {}

  def self.find(key:)
    @active_games[key]
  end

  def self.update(key:, game:)
    @active_games[key] = game
  end

  # some of these could be removed, i was using the readers to test with
  attr_reader :board, :current, :captures, :groups, :move, :size

  def initialize(size: 9, key:)
    puts "initializing game #{key}"
    @size = size
    @move = 1
    @board = (1..size).map { |_| (1..size).map { |_| nil } }
    @current = :black
    @captures = {"black" => 0, "white" => 0}
    @groups = {black: [], white: []}

    @key = key
    GoGame.update(key: key, game: self)

    broadcast_next_turn
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
      .map { |pos| neighbors_in_bounds(pos) }.flatten.uniq
      .count { |pos| !occupied?(pos) }
  end

  def next_player
    @current = current == :black ? :white : :black
  end

  # TODO: add illegal moves, including Ko rule
  def place(pos)
    @board[pos.i][pos.j] = Stone.new(current, pos, move)
    update_groups(pos)
    opponent = current == :black ? :white : :black
    capture(opponent)
    capture(current)
  end

  def broadcast_next_turn
    ActionCable.server.broadcast(game_channel, "move")
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

  def game_channel
    "go:#{@key}"
  end

  def neighbors_in_bounds(pos)
    pos.neighbors.reject { |psn| psn.i.negative? || psn.i >= size || psn.j.negative? || psn.j >= size }
  end

  def occupied?(pos)
    board[pos.i][pos.j]
  end

  # TODO: make the following into its own class
  def update_groups(pos)
    connected_to = current_player_groups_connected_to_pos(pos)

    case connected_to.length
    when 0
      # not connected to anything, make a new group of a single stone
      @groups[current] << [pos]
    when 1
      # connect the stone to the one group it touches
      i = @groups[current].index(connected_to.first)
      @groups[current][i] << pos
    else
      # otherwise the stone is touching multiple groups and we should connect them all
      connect_multiple_groups(connected_to, pos)
    end
  end

  def current_player_groups_connected_to_pos(pos)
    neighbors = neighbors_in_bounds(pos)
    @groups[current].select { |g| neighbors.map { |n| g.include?(n) }.any? }
  end

  # TODO: would be nice to just merge existing groups together, rather than find and delete
  def connect_multiple_groups(groups_to_connect, pos)
    # find the groups' indexes, so we know which ones to remove
    ixs = groups_to_connect.map { |ary| @groups[current].index(ary) }

    # create a new group with all the existing groups' stones plus the new one (pos)
    new_group = stones_in_current_player_groups(ixs) << pos

    # have to reverse here because delete_at mutates the array as we iterate and changes the indexes
    # certainly some proper functional programming would be better :P
    ixs.reverse_each { |i| @groups[current].delete_at(i) }
    @groups[current] << new_group
  end

  def stones_in_current_player_groups(group_indexes)
    group_indexes.map { |i| @groups[current][i] }.flatten
  end
end
