class RestorationGame < ViewComponent::Base
  include Motion::Component
  include WorldGeneration

  attr_reader :air_quality
  attr_reader :board, :index, :selected, :size, :time_passed, :zoom
  attr_reader :berries, :seeds, :saplings, :water, :water_used
  attr_reader :saplings_to_give, :seeds_to_give
  attr_reader :show_info, :show_intro_msg, :show_win_msg, :won

  map_motion :change_selected
  map_motion :close_intro_msg
  map_motion :close_win_msg
  map_motion :paint
  map_motion :toggle_info_msg
  every 1.second, :update

  def initialize(selected: 0)
    @size = 9
    @selected = selected

    @index = {}
    initialize_tiles
    initialize_resources

    generate_world
    @zoom = 3
    @saplings_to_give = 0
    @seeds_to_give = 0
    @show_intro_msg = 1
    @show_win_msg = 0
    @time_passed = 0
    @won = 0
  end

  def change_selected(event)
    @selected = event.target.data[:value].to_i
  end

  def check_win
    if get_tiles(5).size == 0 && @won == 0
      @won = 1
      @show_win_msg = 1
    end
  end

  def close_intro_msg
    @show_intro_msg = 0
  end

  def close_win_msg
    @show_win_msg = 0
  end

  def paint(event)
    x = event.target.data["x"].to_i
    y = event.target.data["y"].to_i

    place(coords_to_index(x, y))
  end

  def toggle_info_msg(event)
    @show_info = event.target.data["value"].to_i
  end

  private

  def evaluate(tile)
    case @board[tile]
    when 1
      if tile_health(tile) < 2
        @board[tile] = 5
      elsif tile_health(tile) > 4 && (check_adjacent(tile, 2) || check_adjacent(tile, 3) || check_adjacent(tile, 4))
        @board[tile] = 2
      end
    when 2
      if tile_health(tile) < 4
        @board[tile] = 1
      elsif tile_health(tile) > 6
        @seeds_to_give += 0.5
      end
    when 3
      if tile_health(tile) < 6
        @board[tile] = 2
      elsif tile_health(tile) > 7
        @saplings_to_give += 1
      end
    when 4
      if tile_health(tile) < 5
        @board[tile] = 2
      elsif tile_health(tile) > 7
        @seeds_to_give += 1
      end
    when 5
      if tile_health(tile) > 3
        @board[tile] = 1
      end
    end
  end

  def initialize_resources
    @berries = 0
    @seeds = 4
    @saplings = 5
  end

  def initialize_tiles
    @index[0] = "water"
    @index[1] = "dirt"
    @index[2] = "grass"
    @index[3] = "tree"
    @index[4] = "berries"
    @index[5] = "cracked"
  end

  def place(loc)
    return if (@board[loc] == 0) || (@board[loc] == 5) || (@board[loc] == 4)
    case @selected
    when 2
      if @seeds > 0 && @bboard[loc] == 1
        @board[loc] = @selected
        @seeds -= 1
      end
    when 3
      if @saplings > 4 && @board[loc] == 2
        @board[loc] = @selected
        @saplings -= 5
      end
    when 4
      if @seeds > 1 && @board[loc] == 2
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
    @saplings_to_give = 0
    @seeds_to_give = 0
    @time_passed += 1
    @board.each_with_index do |b, i|
      waterchk += 2 if b == 3
      waterchk += 0.5 if b == 2
      waterchk += 1 if b == 4
      evaluate(i)
    end

    check_win if @time_passed % 2 == 0
    if time_passed % 10 == 0
      @saplings += @saplings_to_give
      @seeds += @seeds_to_give
    end
    @water_used = waterchk
  end
end
