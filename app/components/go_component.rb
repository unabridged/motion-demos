class GoComponent < ViewComponent::Base
  include Motion::Component

  map_motion :place

  def initialize
    @game = GoGame.new
    @board = @game.display
    @current = @game.current
  end

  def place(event)
    index = event.target.data[:index].to_i
    pos = GoGame::Pos.new((index / 9), index.modulo(9))

    @game.place(pos)
    @board = @game.display

    @game.next_player
    @current = @game.current
  end
end

