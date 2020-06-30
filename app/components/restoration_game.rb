class RestorationGame < ViewComponent::Base

  attr_reader :selected

  def initialize(selected: 0)
    @selected = selected
  end
end
