module Lists
  class ListWithChildren < ViewComponent::Base
    include Motion::Component

    attr_reader :displaying, :channel, :display_channel, :list

    def initialize(channel:, displaying: nil, display_channel: nil)
      @channel = channel
      @displaying = displaying
      @display_channel = display_channel
      @list = Array.new(500) { rand(1..100) }

      stream_from list_display_channel, :list_on_display
      stream_from delete_channel, :on_delete
    end

    def broadcast_list
      ActionCable.server.broadcast(channel, {length: @list.length})
    end

    def authoritative_parent?
      display_channel.present?
    end

    def item_display_channel
      authoritative_parent? ? display_channel : list_display_channel
    end

    ## Streaming
    # Only used if display_channel not sent by parent
    def list_display_channel
      @list_display_channel ||= SecureRandom.uuid
    end

    def list_on_display(msg)
      @displaying = msg
    end

    def delete_channel
      @delete_channel ||= SecureRandom.uuid
    end

    def on_delete(msg)
      @list.delete_at(msg["index"])
      broadcast_list
    end
    ## Streaming
  end
end
