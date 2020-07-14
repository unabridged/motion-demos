module WorldGeneration
  def adjacent_tiles(tile, diagonal)
    tiles = []

    tiles << tile - @size if tile > @size
    tiles << tile - 1 if tile % @size > 0
    tiles << tile + 1 if tile % @size < @size - 1
    tiles << tile + @size if tile / @size < @size - 1

    if diagonal
      tiles << tile - @size - 1 if tile > @size && tile % @size > 0
      tiles << tile - @size + 1 if tile > @size && tile % @size < @size - 1
      tiles << tile + @size - 1 if tile / @size < @size - 1 && tile % @size > 0
      tiles << tile + @size + 1 if tile / @size < @size - 1 && tile % @size < @size - 1
    end

    tiles
  end

  def check_adjacent(loc, type)
    return loc - @size if @board[loc - @size] == type && loc - @size > 0

    return loc - 1 if @board[loc - 1] == type && loc % @size != 0

    return loc + 1 if @board[loc + 1] == type && loc % @size != @size - 1

    return loc + @size if @board[loc + @size] == type && loc / size != @size - 1

    false
  end

  def coords_to_index(x, y)
    (y * @size) + x
  end

  def create_river
    center = rand((@size * @size) - 1)
    loc = center

    placed = 0
    while placed < 10
      direction = rand(3)
      # 0 for up, 1 for down, 2 for left, 3 for right
      case direction
      when 0
        if loc >= @size
          loc -= @size
        end
      when 1
        if loc <= (@size * @size) - 1 - @size
          loc += @size
        end
      when 2
        if loc % @size < @size - 1
          loc += 1
        end
      else
        if loc % @size > 0
          loc -= 1
        end
      end
      if @board[loc] != 0
        @board[loc] = 0
        placed += 1
        @water += 1
      end
    end
  end

  def create_lake
    center = rand((@size * @size) - 1)
    centerx = center % @size
    centery = center / @size

    (centerx - 2..centerx + 2).each do |x|
      (centery - 2..centery + 2).each do |y|
        if distance_probability(x - centerx, y - centery) > rand && @board[coords_to_index(x, y)] != 0
          @board[coords_to_index(x, y)] = 0
          @water += 1
        end
      end
    end
  end

  def distance_probability(x, y)
    distance = Math.sqrt(x * x + y * y)
    if distance <= 1
      1
    else
      (-0.3 * distance + 1).to_f
    end
  end

  def generate_world
    @board = Array.new(@size * @size, 5)
    @water = 0
    @water_used = 0

    # determines whether to generate a lake or a river
    if rand > 0.5
      create_lake
    else
      create_river
    end
  end

  def get_tiles(type)
    tiles = []
    @board.each_with_index do |b, i|
      tiles << i if b == type
    end
    tiles
  end

  def place_dirt
    tiles = get_tiles(0)
    placed = 0

    while placed < 8 && !tiles.empty?
      coord = tiles.sample
      tile = check_adjacent(coord, 5)
      if tile != false
        if @board[tile] == 5
          @board[tile] = 1
          placed += 1
        end
      end
      tiles.delete(coord)
    end
  end
end
