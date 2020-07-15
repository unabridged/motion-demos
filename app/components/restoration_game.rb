class RestorationGame < ViewComponent::Base
  include Motion::Component
  include RestoConstants
  include RestorationInitialize
  include WorldGeneration

  attr_reader :board, :board_viewed, :index, :selected, :board_size, :view_size, :view_corner, :time_passed, :zoom
  attr_reader :berries, :seeds, :saplings, :water, :water_used
  attr_reader :saplings_to_give, :seeds_to_give
  attr_reader :show_info, :show_intro_msg, :show_win_msg, :won

  map_motion :change_selected
  map_motion :close_intro_msg
  map_motion :close_win_msg
  map_motion :paint
  map_motion :pan
  map_motion :toggle_info_msg
  every 1.second, :update

  def initialize
    start
    generate_world
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
    coord = event.target.data["coord"].to_i

    place(coord)
  end

  def pan(event)
    direction = event.target.data["value"].to_i
    case direction
    when RestoConstants::UP
      @view_corner -= @board_size if @view_corner >= @board_size
    when RestoConstants::DOWN
      @view_corner += @board_size if @view_corner / @board_size < @board_size - @view_size
    when RestoConstants::LEFT
      @view_corner -= 1 if @view_corner % @board_size > 0
    when RestoConstants::RIGHT
      @view_corner +=1 if @view_corner % @board_size < @board_size - @view_size
    end
  end

  def toggle_info_msg(event)
    @show_info = event.target.data["value"].to_i
  end

  private

  def evaluate(tile)
    case @board[tile]
    when RestoConstants::DIRT
      if tile_health(tile) < 2
        @board[tile] = RestoConstants::CRACKED
      elsif tile_health(tile) > 4 && (check_adjacent(tile, 2) || check_adjacent(tile, 3) || check_adjacent(tile, 4))
        @board[tile] = RestoConstants::GRASS
      end
    when RestoConstants::GRASS
      if tile_health(tile) < 4
        @board[tile] = RestoConstants::DIRT
      elsif tile_health(tile) > 6
        @seeds_to_give += 0.25
      end
    when RestoConstants::TREE
      if tile_health(tile) < 6
        @board[tile] = RestoConstants::GRASS
      elsif tile_health(tile) > 7
        @saplings_to_give += 1
      end
    when RestoConstants::BERRIES
      if tile_health(tile) < 5
        @board[tile] = RestoConstants::GRASS
      elsif tile_health(tile) > 7
        @seeds_to_give += 0.5
      end
    when RestoConstants::CRACKED
      if tile_health(tile) > 3
        @board[tile] = RestoConstants::DIRT
      end
    end
  end

  def place(loc)
    return if (@board[loc] == 0) || (@board[loc] == 5) || (@board[loc] == 4)
    case @selected
    when 2
      if @seeds > 0 && @board[loc] == RestoConstants::DIRT
        @board[loc] = @selected
        @seeds -= 1
      end
    when 3
      if @saplings > 4 && @board[loc] == RestoConstants::GRASS
        @board[loc] = @selected
        @saplings -= 5
      end
    when 4
      if @seeds > 1 && @board[loc] == RestoConstants::GRASS
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
      when RestoConstants::WATER
        health += 2
      when RestoConstants::GRASS
        health += 1
      when RestoConstants::TREE
        health += 3
      when RestoConstants::BERRIES
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
    if (time_passed % 10).zero?
      @saplings += @saplings_to_give
      @seeds += @seeds_to_give
    end
    @water_used = waterchk
  end
end
