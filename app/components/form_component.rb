class FormComponent < ViewComponent::Base
  include Motion::Component

  delegate :validation_messages, :valid_class, to: :helpers

  attr_reader :signup, :disabled

  map_motion :validate

  def initialize
    @signup = SignUp.new
    @disabled = !signup.valid?
    @changed = Set.new
  end

  def validate(event)
    @changed << event.target.data[:field].to_sym
    signup.assign_attributes(signup_attributes(event.form_data))
    @disabled = !signup.valid?
  end

  private

  def signup_attributes(params)
    params.
      require(:sign_up).
      permit(:name, :email, :favorite_color, :birthday, :plan, :terms, :comments)
  end
end
