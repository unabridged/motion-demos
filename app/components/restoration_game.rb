class RestorationGame < ViewComponent::Base
  include Motion::Component

  def initialize(selected: 0)
    @selected = selected
  end
end
