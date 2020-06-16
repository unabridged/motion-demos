class FormComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :signup

  map_motion :validate

  def initialize
    @signup = SignUp.new
    @changed = Set.new
  end

  def validate(event)
    @changed << event.target.data[:field].to_sym
    signup.assign_attributes(signup_attributes(event.form_data))
    signup.validate
  end

  private

  def signup_attributes(params)
    params.
      require(:sign_up).
      permit(:name, :email, :favorite_color, :birthday, :plan, :accept, :comments)
  end
end
