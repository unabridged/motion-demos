module Lists
  class ListItemRow < ViewComponent::Base
    include Motion::Component

    attr_reader :item, :item_display_channel, :delete_channel, :index

    map_motion :delete
    map_motion :display

    def initialize(item:, item_display_channel:, delete_channel:, index:)
      @item = item
      @item_display_channel = item_display_channel
      @delete_channel = delete_channel
      @index = index
    end

    ## Map Motion
    def display
      ActionCable.server.broadcast(item_display_channel, item)
    end

    def delete
      ActionCable.server.broadcast(delete_channel, {index: index, item: item})
    end
    ## end map motion
  end
end
