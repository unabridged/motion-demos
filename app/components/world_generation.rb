module WorldGeneration

  def coords_to_index(x, y)
    (y * @size) + x
  end 

  def create_river
    center = rand((@size*@size)-1)
    loc = center

    placed = 0
    while placed < 10
      direction = rand(3)
      # 0 for up, 1 for down, 2 for left, 3 for right
      case direction
      when 0
        if (loc >= @size)
          loc -= @size
        end
      when 1
        if (loc <= (@size * @size) - 1 - @size)
          loc += @size
        end
      when 2
        if (loc % @size < @size - 1)
          loc += 1
        end
      else
        if (loc % @size > 0)
          loc -= 1
        end
      end
      if (@board[loc] != 0)
        @board[loc] = 0
        placed += 1
      end
    end
  end

  def create_lake
    center = rand((@size*@size)-1)
    centerx = center % @size
    centery = center / @size

    (centerx-2..centerx+2).each do |x|
      (centery-2..centery+2).each do |y|

        @board[coords_to_index(x, y)] = 0 if distance_probability(x-centerx, y-centery) > rand()
      end
    end
  end

  def distance_probability(x, y)
    distance = Math.sqrt(x*x + y*y)
    if distance <= 1
      return 1
    else
      (-0.3*distance + 1).to_f
    end
  end

  def generate_world
    @size = 9
    @board = Array.new(@size * @size, 1)

    # determines whether to generate a lake or a river
    if rand() > 0.5
      create_lake
    else
      create_river
    end

    placed = 0

    while placed < 5
      coord = rand((@size*@size)-1)
      if(@board[coord] == 1)
        @board[coord] = 2
        placed += 1
      end
    end

    placed = 0

    while placed < 1
      coord = rand((@size*@size)-1)
      if(@board[coord] == 1)
        @board[coord] = 3
        placed += 1
      end
    end
  end  
end
