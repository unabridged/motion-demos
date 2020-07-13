class UserDashboardComponent < ApplicationComponent
  include Motion::Component
  attr_reader :user, :messages, :sent_messages, :offset, :per_page

  map_motion :change_list

  def initialize(user:)
    @user = user
    @offset = 0
    @per_page = 20
    @messages = user.messages.paginated(offset, per_page).map{|msg| ::MessageDecorator.new(msg) }
    @sent_messages = user.sent_messages.paginated(offset, per_page).map{|msg| ::MessageDecorator.new(msg) }
    @messages_count = user.messages.count
    @sent_messages_count = user.sent_messages.count
    @current_list = :messages
    @reading = nil

    stream_from on_msg_click_callback.broadcast, :reading_message
    stream_messages
  end

  def on_msg_click_callback
    @on_msg_click_callback ||= bind(:reading_message)
  end

  def current_list
    send(@current_list)
  end

  def starred_list
    [*messages, *sent_messages].select { |msg| msg.starred? }
  end

  def change_list(event)
    @current_list = event.target.data[:list].to_sym
  end

  def stream_messages
    # stream_from to_message_channel, :add_message
    # stream_from from_message_channel, :add_sent_message
    # stream_from reading_message_channel, :reading_message

    # [*messages, *sent_messages].each do |msg|
    #   stream_from update_message_channel(msg), :update_message
    #   stream_from delete_message_channel(msg), :delete_message
    # end
  end

  # STREAMS
  def add_message(msg)
    message = find_message(msg["id"])
    puts message.inspect

    return unless message

    add_message_to_queue(@messages, message)

    @current_list = @messages
  end

  def add_sent_message(msg)
    message = find_message(msg["id"])
    return unless message

    add_message_to_queue(@sent_messages, message)
  end

  def reading_message(msg)
    @reading = ::MessageDecorator.new(Message.find_by(id: msg["id"]))
  end

  def update_message(msg)
    message = find_message(msg["id"])
    return unless message

    message.status = msg["status"] if msg["status"]
    @messages = update_message_in_queue(@messages, message)
    @sent_messages = update_message_in_queue(@sent_messages, message)
  end

  def delete_message(msg)
    id = msg["id"]
    @messages = delete_message_from_queue(@messages, id)
    @sent_messages = delete_message_from_queue(@sent_messages, id)
  end
  # END STREAMS

  private

  def update_message_in_queue(queue, message)
    queue.map { |msg| msg.id == message.id ? ::MessageDecorator.new(message) : msg }
  end

  def add_message_to_queue(queue, message)
    # Add new message to start of list
    queue.unshift(::MessageDecorator.new(message)) if offset == 0
  end

  def delete_message_from_queue(queue, id)
    queue.reject { |msg| msg.id == id }
  end

  def find_message(id)
    Message.find_by(id: id)
  end

  def from_message_channel
    "messages:from:#{user_id}"
  end

  def to_message_channel
    "messages:to:#{user_id}"
  end

  def update_message_channel(message)
    "messages:read:#{message.id}"
  end

  def delete_message_channel(message)
    "messages:delete:#{message.id}"
  end

  def user_id
    user.id
  end
end
