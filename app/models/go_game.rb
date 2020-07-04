# this class represents everything needed to build a square Go board,
# track the state of the game, and possibly produce a game record based
# on the stones placed on the board.
class GoGame
  # a position on the board, where top left is 0,0
  # represents indexes into the matrix representing the board
  # i is the row and j is the column in the matrix
  Pos = Struct.new(:i, :j) do
    def +(pos)
      Pos.new(pos.i + i, pos.j + j)
    end

    def neighbors
      [Pos.new(1,0), Pos.new(0,1), Pos.new(-1,0), Pos.new(0,-1)].map { |dir| self + dir }
    end
  end

  # this represents a stone placed on a board at a given position
  # as well as the move number sequence of when it was played
  # color : :black | :white
  # pos : Pos
  # num : Integer
  Stone = Struct.new(:color, :pos, :num)

  # some of these could be removed, i was using the readers to test with
  attr_reader :board, :current, :captures, :groups, :move, :size

  def initialize(size: 9)
    @size = size
    @move = 1
    @board = (1..size).map { |_| (1..size).map { |_| nil } }
    @current = :black
    @captures = {"black" => 0, "white" => 0}
    @groups = {
      black: [],
      white: [],
    }
  end

  # flattens the board for and only includes stone color for the view
  def display
    board.flatten.map { |stone| stone&.color }
  end

  # TODO: this could be private, currently tested as a public method
  def liberties(group)
    group.map { |pos| neighbors_in_bounds(pos) }.flatten.uniq
      .reject { |pos| occupied?(pos) }
      .count
  end

  def next_player
    @current = current == :black ? :white : :black
  end

  # TODO: add illegal moves, including Ko rule
  def place(pos)
    @board[pos.i][pos.j] = Stone.new(current, pos, move)
    update_groups(pos)
    capture
  end

  def legal_move?(pos)
    return true unless occupied?(pos)
  end

  private

  def capture
    opponent = current == :black ? :white : :black
    captured = @groups[opponent].select { |grp| liberties(grp).zero? }

    captured.each do |grp|
      grp.each { |pos| @board[pos.i][pos.j] = nil }
      @captures[opponent.to_s] += grp.length
      @groups[opponent].delete(grp)
    end
  end

  def neighbors_in_bounds(pos)
    pos.neighbors.reject { |pos| pos.i < 0 || pos.i >= size || pos.j < 0 || pos.j >= size }
  end

  def occupied?(pos)
    board[pos.i][pos.j]
  end

  def update_groups(pos)
    neighbors = neighbors_in_bounds(pos)
    connected_to = @groups[current].select { |g| neighbors.map { |n| g.include?(n) }.any? }

    case connected_to.length
    when 0
      @groups[current] << [pos]
    when 1
      i = @groups[current].index(connected_to.first)
      @groups[current][i] << pos
    else
      ixs = connected_to.map { |ary| @groups[current].index(ary) }
      new_group = ixs.map { |i| @groups[current][i] }.flatten << pos

      # have to reverse because the indexes as delete_all mutates the array
      # perhaps some proper functional programming is better :P
      ixs.reverse.each { |i| @groups[current].delete_at(i) }
      @groups[current] << new_group
    end
  end
end
