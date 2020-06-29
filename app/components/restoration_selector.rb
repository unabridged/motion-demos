class RestorationSelector < ViewComponent::Base
  include Motion::Component

  map_motion :change_selected

  def initialize
  end

  def change_selected(event)
    session[:selected] = 2
  end
end
