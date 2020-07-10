class RestorationGame < ViewComponent::Base
  include Motion::Component
  include WorldGeneration

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

  def initialize_resources
    @berries = 0
    @seeds = 0
    @saplings = 0
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
      @saplings += gather_chance
      @board[loc] = 1
    end
  end

  def gather_chance
    rand(2..4) / 2
  end

  def place(loc)
    return if @board[loc] == 0 or @board[loc] == 5
    case @selected    
    when 2
      if @seeds > 0
        @board[loc] = @selected
        @seeds -= 1
      end
    when 3
      if @saplings > 0
        @board[loc] = @selected
        @saplings -= 1
      end
    when 4
      if @seeds > 0
        @board[loc] = @selected
        @seeds -= 1
      end
    end
  end

  def update
    waterchk = 0
    @board.each do |b|
      waterchk += 2 if b == 3
      waterchk += 0.5 if b == 2
      waterchk += 1 if b == 4
    end

    @water_used = waterchk
  end
end
