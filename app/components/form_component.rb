class FormComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :signup

  map_motion :validate

  def initialize
    @signup = SignUp.new
  end

  def validate(event)
    kvs = event.form_data

    signup.assign_attributes(kvs)
    signup.validate
  end
end
