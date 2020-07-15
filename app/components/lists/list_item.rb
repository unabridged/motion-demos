module Lists
  class ListItem < ViewComponent::Base
    include Motion::Component

    attr_reader :item, :item_display_channel

    map_motion :stop_displaying
    map_motion :count

    def initialize(item:, item_display_channel:, channel:)
      @item = item
      @item_display_channel = item_display_channel
      @count = item
      @channel = channel
    end

    ## Map Motion
    def stop_displaying
      ActionCable.server.broadcast(item_display_channel, nil)
    end

    def count(event)
      @count += event.element.data["value"].to_i
      ActionCable.server.broadcast(@channel, {count: @count})
    end
    ## end map motion
  end
end
