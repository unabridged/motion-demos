module Go
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

    def neighbors_in_bounds(size)
      neighbors.reject { |psn| psn.i.negative? || psn.i >= size || psn.j.negative? || psn.j >= size }
    end
  }
end
