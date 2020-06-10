class CalculatorComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :total

  map_action :add_one

  def initialize(total: 0)
    @total = total
  end

  def add_one
    @total += 1
  end
end
