class GoComponent < ViewComponent::Base
  include Motion::Component

  map_motion :place

  def initialize
    @positions = (1..81).map { |_| nil }
    @current = :black
  end

  def place(event)
    index = event.target.data[:index].to_i
    @positions[index] = @current
    @current = next_player
  end

  private

  def next_player
    @current == :black ? :white : :black
  end
end
