class RestorationGame < ViewComponent::Base
  include Motion::Component

  @selected = 0
  map_motion :do_stuff

  def initialize
  end
end
