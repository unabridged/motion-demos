class RestorationSelector < ViewComponent::Base
  include Motion::Component

  map_motion :change_selected

  def initialize
  end

  def change_selected(value)
    @selected = value
  end
end
