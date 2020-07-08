class RestorationGame < ViewComponent::Base
  include Motion::Component
  include WorldGeneration

  attr_reader :board, :index, :selected, :size, :zoom
  attr_reader :berries, :seeds, :saplings

  map_motion :change_selected
  map_motion :paint

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
  end

  def gather(loc)
    case @board[loc]
    when 2
      @seeds += 1
      @board[loc] = 1
    when 3
      @saplings += 1
      @board[loc] = 1
    end
  end

  def place(loc)
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
end
