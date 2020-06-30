class RestorationSelector < ViewComponent::Base
  include Motion::Component

  attr_reader :selected

  map_motion :change_selected

  def initialize(selected: 0)
    @selected = selected
  end

  def change_selected(event)
    @selected = event.target.data[:value]
  end
end
