module Lists
  class ListItem < ViewComponent::Base
    include Motion::Component

    attr_reader :item, :id, :tagname

    map_motion :delete

    def initialize(item:, index:, id: nil, id_location: nil, tagname: "li", delete_channel:)
      @item = item
      @index = index
      @id = id
      @id_location = id_location
      @tagname = tagname
      @delete_channel = delete_channel
    end

    def outer_id
      return id if @id_location == :outer
    end

    def inner_id
      return id if @id_location == :inner
    end

    ## Map Motion
    def delete
      ActionCable.server.broadcast(@delete_channel, {id: item.id, index: @index})
    end
    ## end map motion
  end
end
