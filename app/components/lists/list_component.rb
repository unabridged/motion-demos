module Lists
  class ListComponent < ViewComponent::Base
    include Motion::Component

    attr_reader :list, :list_type, :attribute

    Item = Struct.new(:value, :id)

    map_motion :change_list
    map_motion :change_attribute
    map_motion :delete

    def initialize
      @list = Array.new(50) { |i| Item.new(rand(1..100), i) }
      @attribute = :id
      @list_type = :inside_child
      stream_from delete_channel, :on_delete
    end

    def attributes
      {
        id: "Value saved on the item",
        index: "Index of current list",
        no_id: "Display no id"
      }
    end

    def list_types
      {
        inside_child: "#{attribute} is inside child component",
        inside_nested_child: "#{attribute} is nested inside child component",
        outside_child: "#{attribute} is outside child component",
        no_child: "list has no child component"
      }
    end

    def will_fail?
      return false if attribute == :no_id
      return false if attribute == :index
      return false if list_type == :inside_nested_child
      return false if list_type == :no_child

      true
    end

    def display_id(item, index)
      case attribute
      when :index
        index
      when :id
        item.id
      when :no_id
        nil
      end
    end

    def display_location
      case list_type
      when :inside_child, :no_child
        :outer
      when :outside_child
        :outside
      when :inside_nested_child
        :inner
      end
    end

    ## Map motion
    def change_list(event)
      @list_type = event.element.data["value"].to_sym
    end

    def change_attribute(event)
      @attribute = event.element.data["value"].to_sym
    end

    def delete(event)
      @list.delete_at(event.element.data["value"].to_i)
    end
    ## End map motion

    ## Streaming
    def delete_channel
      @delete_channel ||= SecureRandom.uuid
    end

    def on_delete(msg)
      @list.delete_at(msg["index"])
    end
    ## Streaming
  end
end
