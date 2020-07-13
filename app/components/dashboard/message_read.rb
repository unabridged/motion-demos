module Dashboard
  class MessageRead < ApplicationComponent
    include Motion::Component
    include SvgHelper # helpers must be included from parent, or included

    attr_reader :user, :message

    delegate :id, :content, :from, :to, :display_sent_at, :read?, to: :message, allow_nil: true

    map_motion :dismiss

    def initialize(message:, on_exit: nil)
      @message = message
      @on_exit = on_exit
      @replies = []

      # TODO - this line should not be necessary
      stream_from reply_sent_callback.broadcast, :reply_sent
    end

    ## Map motions
    def dismiss(event)
      return unless clicked_on_close_targets?(event)

      @on_exit.call({id: nil})
    end
    ## End map motions

    def clicked_on_close_targets?(event)
      close_targets.include? event.target.data["id"]
    end

    def close_targets
      ["overlay", "close-button"]
    end

    def reply_sent_callback
      @reply_sent_callback ||= bind(:reply_sent)
    end

    def reply_sent(msg)
      message = Message.find_by(id: msg["id"])
      @replies << ::MessageDecorator.new(message) if message.present?
    end
  end
end
