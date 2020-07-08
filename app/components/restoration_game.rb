class RestorationGame < ViewComponent::Base
  include Motion::Component

  attr_reader :board, :index, :selected, :size, :zoom
  attr_reader :berries, :seeds, :saplings

  map_motion :change_selected
  map_motion :paint

  def initialize(selected: 0)
    @size = 9
    @selected = selected
    @board = Array.new(@size * @size, 1)
    @index = Hash.new
    initialize_tiles

    generate_world
    @zoom = 3
  end

  def change_selected(event)
    @selected = event.target.data[:value].to_i
  end

  def paint(event)
    x = event.target.data["x"].to_i
    y = event.target.data["y"].to_i
    @board[coords_to_index(x, y)] = @selected
  end

  private

  def coords_to_index(x, y)
    (y * @size) + x
  end 

  def create_river
    center = rand((@size*@size)-1)
    loc = center


    (0..10).each do
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
      @board[loc] = 0
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
  end  

  def initialize_tiles
    @index[0] = "water"
    @index[1] = "dirt"
    @index[2] = "grass"
    @index[3] = "tree"
  end
end
