class RestorationGame < ViewComponent::Base
  include Motion::Component

  attr_reader :selected
  attr_reader :board
  attr_reader :index

  map_motion :paint

  def initialize(selected:)
    @selected = selected
    @board = Array.new(81, 1)
    @index = Hash.new
    @index[0] = "waater"
    @index[1] = "water"
    @index[2] = "grass"
    @index[3] = "tree"
  end

  def paint(event)
    x = event.target.data["x"].to_i
    y = event.target.data["y"].to_i
    @selected = event.target.data["selected"].to_i
    @board[coords_to_index(x, y)] = @selected
  end

  private

  def coords_to_index(x, y)
    (x * 9) + y
  end 
end
