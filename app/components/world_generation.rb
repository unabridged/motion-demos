module WorldGeneration
  def adjacent_tiles(tile, diagonal)
    tiles = []

    tiles << tile - @board_size if tile >= @board_size
    tiles << tile - 1 if tile % @board_size > 0
    tiles << tile + 1 if tile % @board_size < @board_size - 1
    tiles << tile + @board_size if tile / @board_size < @board_size - 1

    if diagonal
      tiles << tile - @board_size - 1 if tile >= @board_size && tile % @board_size > 0
      tiles << tile - @board_size + 1 if tile >= @board_size && tile % @board_size < @board_size - 1
      tiles << tile + @board_size - 1 if tile / @board_size < @board_size - 1 && tile % @board_size > 0
      tiles << tile + @board_size + 1 if tile / @board_size < @board_size - 1 && tile % @board_size < @board_size - 1
    end

    tiles
  end

  def check_adjacent(loc, type)
    return loc - @board_size if @board[loc - @board_size] == type && loc - @board_size >= 0

    return loc - 1 if @board[loc - 1] == type && loc % @board_size != 0

    return loc + 1 if @board[loc + 1] == type && loc % @board_size != @board_size - 1

    return loc + @board_size if @board[loc + @board_size] == type && loc / @board_size != @board_size - 1

    false
  end

  def coords_to_index(x, y)
    (y * @board_size) + x
  end

  def create_river
    center = rand((@board_size * @board_size) - 1)
    loc = center

    placed = 0
    while placed < 10
      direction = rand(3)
      # 0 for up, 1 for down, 2 for left, 3 for right
      case direction
      when 0
        if loc >= @board_size
          loc -= @board_size
        end
      when 1
        if loc <= (@board_size * @board_size) - 1 - @board_size
          loc += @board_size
        end
      when 2
        if loc % @board_size < @board_size - 1
          loc += 1
        end
      else
        if loc % @board_size > 0
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
    center = rand((@board_size * @board_size) - 1)
    centerx = center % @board_size
    centery = center / @board_size

    (centerx - 2..centerx + 2).each do |x|
      (centery - 2..centery + 2).each do |y|
        if distance_probability(x - centerx, y - centery) > rand && @board[coords_to_index(x, y)] != 0
          @board[coords_to_index(x, y)] = 0
          @water += 1
        end
      end
    end
  end

  def create_random_water
    if rand > 0.5
      create_lake
    else
      create_river
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
    @board = Array.new(@board_size * @board_size, 5)
    @water = 0
    @water_used = 0

    create_random_water

    create_random_water if rand > 0.5

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
