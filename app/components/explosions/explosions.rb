module Explosions
  class Explosions < ViewComponent::Base
    include Motion::Component

    attr_reader :area, :board, :center, :exploding, :size

    map_motion :explode

    every 0.05.second, :update

    def initialize(size)
      @exploding = false
      @size = size
      @area = size * size
      @board = Array.new(@area, 0)
    end

    def explode(event)
      @exploding = true
      @center = event.target.data[:index].to_i
      @count = 0
    end

    def exploding?(i)
      @board[i] == 1
    end

    def range
      @size * @size - 1
    end

    def row_end?(i)
      i % @size == 0 && i != 0
    end

    def update
      if @exploding
        @count += 1

        @board = @board.map.with_index { |val, i|
          if val == 0 && distance(i, @center) == @count - 1
            1
          else
            0
          end
        }

        if @count >= @size * 1.5
          @exploding = false
          @count = 0
        end
      end
    end

    private

    def distance(a, b)
      horiz = (a % size) - (b % size)
      vert = (a / size) - (b / size)

      Math.sqrt(horiz**2 + vert**2).floor
    end
  end
end
