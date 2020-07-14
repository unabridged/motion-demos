class UserDashboardComponent < ApplicationComponent
  include SvgHelper
  include Motion::Component
  attr_reader :user, :current_list

  def initialize(user:)
    @user = user

    @current_list = :messages
    @message = nil
    @msg = 0
    # TODO: remove, this should not be necessary
    stream_from change_list_callback.broadcast, :change_list
    stream_from reading_callback.broadcast, :reading
    stream_from "messages:from:#{user.id}", :messages
    stream_from "messages:to:#{user.id}", :messages
  end

  def reading_callback
    @reading_callback ||= bind(:reading)
  end

  def change_list_callback
    @change_list_callback ||= bind(:change_list)
  end

  def messages
    @msg += 1
  end

  def change_list(list)
    @current_list = list.to_sym
  end

  def reading(msg)
    message = Message.find_by(id: msg["id"])
    return @reading = ::MessageDecorator.new(message) if message

    @reading = nil
  end
end
