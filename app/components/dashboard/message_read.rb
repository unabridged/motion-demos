module Dashboard
  class MessageRead < ApplicationComponent
    include Motion::Component
    include SvgHelper # helpers must be included from parent, or included

    attr_reader :user, :message

    delegate :id, :content, :from, :to, :display_sent_at, :read?, to: :message, allow_nil: true

    def initialize(message:, user:, on_exit: nil, on_next: nil, on_previous: nil)
      @message = message
      @user = user
      @on_exit = on_exit
      @on_next = on_next
      @on_previous = on_previous
      @replies = []

      # TODO - this line should not be necessary
      stream_from reply_sent_callback.broadcast, :reply_sent
    end

    def show_response?
      @on_exit.present?
    end

    ## Map motions
    def dismiss(event)
      return unless clicked_on_close_targets?(event)

      @on_exit.call({id: nil})
    end
    ## End map motions

    def reply_sent_callback
      @reply_sent_callback ||= bind(:reply_sent)
    end

    def to_new_message
      return message.to if user == message.from

      message.from
    end

    def reply_sent(msg)
      message = Message.find_by(id: msg["id"])
      @replies << ::MessageDecorator.new(message) if message.present?
    end
  end
end
