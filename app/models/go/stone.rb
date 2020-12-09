module Go
  # this represents a stone placed on a board at a given position
  # as well as the move number sequence of when it was played
  # color : :black | :white
  # pos : Pos
  # num : Integer
  Stone = Struct.new(:color, :pos, :num)
end
