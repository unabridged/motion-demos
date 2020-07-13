class RestorationGame < ViewComponent::Base
  include Motion::Component
  include WorldGeneration

  attr_reader :air_quality
  attr_reader :board, :index, :selected, :size, :zoom
  attr_reader :berries, :seeds, :saplings, :water, :water_used

  map_motion :change_selected
  map_motion :paint
  every 1.second, :update

  def initialize(selected: 0)
    @size = 9
    @selected = selected
    
    @index = Hash.new
    initialize_tiles
    initialize_resources

    generate_world
    @zoom = 3
  end

  def change_selected(event)
    @selected = event.target.data[:value].to_i
  end

  def paint(event)
    x = event.target.data["x"].to_i
    y = event.target.data["y"].to_i
    if(@selected >= 0)
      place(coords_to_index(x, y))
    else
      gather(coords_to_index(x, y))
    end
  end

  private

  def evaluate(tile)
    case @board[tile]
    when 1
      if tile_health(tile) < 1
        @board[tile] = 5
      end
    when 2
    when 3
    when 4
    when 5
      if tile_health(tile) > 3
        @board[tile] = 1
      end
    end
  end

  def initialize_resources
    @berries = 0
    @seeds = 4
    @saplings = 1
  end

  def initialize_tiles
    @index[0] = "water"
    @index[1] = "dirt"
    @index[2] = "grass"
    @index[3] = "tree"
    @index[4] = "berries"
    @index[5] = "cracked"
  end

  def gather(loc)
    case @board[loc]
    when 2
      @seeds += gather_chance
      @board[loc] = 1
    when 3
      @saplings += 1
      @board[loc] = 1
    when 4
      @seeds += gather_chance
      @board[loc] = 1
    end
  end

  def gather_chance
    rand(2..4) / 2
  end

  def place(loc)
    return if @board[loc] == 0 or @board[loc] == 5 or @board[loc] == 4
    case @selected    
    when 2
      if @seeds > 0
        @board[loc] = @selected
        @seeds -= 1
      end
    when 3
      if @saplings > 0 and @board[loc] == 2
        @board[loc] = @selected
        @saplings -= 1
      end
    when 4
      if @seeds > 1 and @board[loc] == 2
        @board[loc] = @selected
        @seeds -= 2
      end
    end
  end

  def tile_health(tile)
    health = 0
    tiles = adjacent_tiles(tile, true)

    tiles.each do |t|
      case @board[t]
      when 0
        health += 2
      when 2
        health += 1
      when 3
        health += 3
      when 4
        health += 2
      end
    end

    health
  end

  def update
    waterchk = 0
    @board.each_with_index do |b, i|
      waterchk += 2 if b == 3
      waterchk += 0.5 if b == 2
      waterchk += 1 if b == 4
      evaluate(i)
    end

    @water_used = waterchk
  end
end
