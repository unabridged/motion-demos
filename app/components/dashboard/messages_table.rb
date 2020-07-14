module Dashboard
  class MessagesTable < ApplicationComponent
    include Motion::Component
    include SvgHelper

    attr_reader :user, :on_click, :reading, :offset, :per_page, :total

    map_motion :change_offset
    map_motion :paginate

    def initialize(user:, message_type:, on_click:, reading:)
      @user = user
      @message_type = message_type

      @per_page = 10
      @offset = 0
      @messages = message_query
      @total = user.send(message_type).count
      @on_click = on_click
      @reading = reading
    end

    def message_query
      user
        .send(@message_type)
        .paginated(offset, per_page)
        .eager_load(:from, :to)
        .map { |msg| ::MessageDecorator.new(msg) }
    end

    def messages_start
      offset * per_page + 1
    end

    def messages_end
      [((offset + 1) * per_page), total].min
    end

    def paginate(event)
      if event.element.data["value"] == "increase"
        @offset += 1
      else
        @offset = [0, @offset - 1].max
      end
    end

    def paginate_increase?
      total > ((offset + 1) * per_page)
    end

    def paginate_decrease?
      offset > 0
    end

    private

    def update_message_in_queue(queue, message)
      queue.map { |msg| msg.id == message.id ? ::MessageDecorator.new(message) : msg }
    end

    def update_message_channel(message)
      "messages:read:#{message.id}"
    end

    def user_id
      user.id
    end
  end
end
