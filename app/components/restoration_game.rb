class RestorationGame < ViewComponent::Base
  include Motion::Component

  attr_reader :selected
  attr_reader :board
  attr_reader :x, :y

  map_motion :paint

  def initialize(selected: 0)
    @selected = selected
    @board = Array.new(81, 1)
  end

  def paint(event)
    p event.target.data.inspect
    x = event.target.data["x"]
    y = event.target.data["y"]
    # @board[coords_to_index(x, y)] = 2
  end

  private

  def coords_to_index(x, y)
    (x * 9) + y
  end 
end
