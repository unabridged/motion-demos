module Dashboard
  class MessagesTable < ApplicationComponent
    include Motion::Component
    include SvgHelper

    attr_reader :user, :reading, :offset, :per_page, :total

    map_motion :change_offset
    map_motion :paginate

    def initialize(user:, message_type:)
      @user = user
      @message_type = message_type

      @per_page = 10
      @offset = 0
      @messages = paginated_message_query
      @total = message_query.count

      stream_from on_click.broadcast, :on_reading
    end

    def on_reading(msg)
      @reading = ::MessageDecorator.new(Message.find_by(id: msg["id"]))
    end

    def on_click
      @on_click ||= bind(:on_reading)
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

    def paginated_message_query
      message_query
        .paginated(offset, per_page)
        .eager_load(:from, :to)
        .map { |msg| ::MessageDecorator.new(msg) }
    end

    def message_query
      user.send(@message_type)
    end
  end
end
