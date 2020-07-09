module Dashboard
  class MessageRead < ViewComponent::Base
    include Motion::Component
    include SvgHelper
    DATE_FORMAT = "%m/%d/%Y %I:%M:%S%p"
    attr_reader :user, :message

    delegate :id, :content, :from, :to, :read?, to: :message, allow_nil: true

    map_motion :dismiss

    def initialize(message:, reading_message_channel:)
      @message = message
      @reading_message_channel = reading_message_channel
    end

    ## Map motions
    def dismiss(event)
      return unless clicked_on_close_targets?(event)

      ActionCable.server.broadcast(@reading_message_channel, {id: nil})
    end
    ## End map motions

    def clicked_on_close_targets?(event)
      close_targets.include? event.target.data["id"]
    end

    def close_targets
      ["overlay", "close-button"]
    end

    def sent_at
      message

      message.created_at.strftime(DATE_FORMAT)
    end
  end
end
