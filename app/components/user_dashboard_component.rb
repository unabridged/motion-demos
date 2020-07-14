class UserDashboardComponent < ApplicationComponent
  include SvgHelper
  include Motion::Component
  attr_reader :user, :current_list

  def initialize(user:)
    @user = user

    @current_list = :messages

    # TODO: remove, this should not be necessary
    stream_from change_list_callback.broadcast, :change_list
  end

  def change_list_callback
    @change_list_callback ||= bind(:change_list)
  end

  def change_list(list)
    @current_list = list.to_sym
  end
end
