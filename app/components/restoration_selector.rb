class RestorationSelector < ViewComponent::Base
  include Motion::Component

  map_motion :change_selected

  def initialize
  end

  def change_selected(event)
    @selected = event.target.data[:value]
  end
end
