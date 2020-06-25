class FormComponent < ViewComponent::Base
  include Motion::Component

  delegate :validation_messages, :valid_class, :state_options,
    :country_options, to: :helpers

  attr_reader :signup, :disabled, :saved

  map_motion :validate
  map_motion :save

  def initialize
    @signup = Signup.new
    @disabled = !signup.valid?
    @changed = Set.new
    @saved = false
  end

  def validate(event)
    @saved = false
    @changed << event.target.data[:field].to_sym
    signup.assign_attributes(signup_attributes(event.form_data))
    @disabled = !signup.valid?
  end

  def save(event)
    # For demo purposes, don't save anything.
    @saved = true
  end

  def state_select?
    signup.errors[:country].empty?
  end

  private

  def signup_attributes(params)
    params.
      require(:signup).
      permit(:name, :email, :favorite_color, :birthday, :plan, :terms, :comments, :country, :state)
  end
end
