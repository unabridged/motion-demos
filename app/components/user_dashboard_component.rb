class UserDashboardComponent < ViewComponent::Base
  include Motion::Component
  attr_reader :user

  def initialize(user:)
    @user = user
  end
end
