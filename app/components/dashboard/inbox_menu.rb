module Dashboard
  class InboxMenu < ApplicationComponent
    include Motion::Component
    include SvgHelper

    attr_reader :user, :on_click, :offset, :per_page, :total

    map_motion :change_list

    def initialize(user:, on_click:)
      @user = user
      @on_click = on_click
      set_counts

      stream_messages
    end

    def stream_messages
      stream_from to_message_channel, :count_messages
      stream_from from_message_channel, :count_messages
    end

    def change_list(event)
      @on_click.call(event.element.data[:list])
    end

    def count_messages
      set_counts
    end

    def set_counts
      @messages_count = user.messages.count
      @sent_messages_count = user.sent_messages.count
    end

    def from_message_channel
      "messages:from:#{user_id}"
    end

    def to_message_channel
      "messages:to:#{user_id}"
    end

    def user_id
      user.id
    end
  end
end
