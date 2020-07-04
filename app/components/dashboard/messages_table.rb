module Dashboard
  class MessagesTable < ViewComponent::Base
    include Motion::Component
    attr_reader :user, :messages, :sent_messages

    map_motion :change_list

    def initialize(user:)
      @user = user
      @messages = user.messages.order(:created_at).map { |msg| ::MessageDecorator.new(msg) }
      @sent_messages = user.sent_messages.order(:created_at).map { |msg| ::MessageDecorator.new(msg) }
      @current_list = :messages
      @displaying = nil

      stream_messages
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
      stream_from to_message_channel, :add_message
      stream_from from_message_channel, :add_sent_message

      [*messages, *sent_messages].each do |msg|
        stream_from update_message_channel(msg), :update_message
        stream_from delete_message_channel(msg), :delete_message
      end
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
      message = find_message(id(msg))
      return unless message

      add_message_to_queue(@sent_messages, message)
    end

    def update_message(msg)
      message = find_message(msg["id"])
      puts message.inspect
      message.status = msg["status"]
      return unless message

      puts @messages.find { |msg| msg.id == message.id ? message : msg }.inspect

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
      queue.push(::MessageDecorator.new(message))
      stream_from update_message_channel(message), :update_message
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
end
