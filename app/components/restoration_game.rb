class RestorationGame < ViewComponent::Base
  include Motion::Component

  attr_reader :selected
  attr_reader :board

  map_motion :paint

  def initialize(selected:)
    @selected = selected
    @board = Array.new(81, 1)
  end

  def paint(event)
    x = event.target.data["x"].to_i
    y = event.target.data["y"].to_i
    @board[coords_to_index(x, y)] = 2
  end

  private

  def coords_to_index(x, y)
    (x * 9) + y
  end 
end
