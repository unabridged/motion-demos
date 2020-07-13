module Dashboard
  class MessageRead < ViewComponent::Base
    include Motion::Component
    include SvgHelper # helpers must be included from parent, or included

    attr_reader :user, :message

    delegate :id, :content, :from, :to, :display_sent_at, :read?, to: :message, allow_nil: true

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
  end
end
