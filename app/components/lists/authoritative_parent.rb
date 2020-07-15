module Lists
  class AuthoritativeParent < ViewComponent::Base
    include Motion::Component

    attr_reader :displaying, :channel

    map_motion :list_change

    def initialize
      @displaying = nil
      @channel = SecureRandom.uuid
      @list_type = :list_with_children

      stream_from display_channel, :on_display
    end

    ## Streaming
    def display_channel
      @display_channel ||= SecureRandom.uuid
    end

    def on_display(msg)
      @displaying = msg
    end
    ## Streaming

    ## Map motion
    def list_change(evnet)
      @list_type = event.element.data["value"].to_sym
    end
    ## End map motion

    def list_klass
      case @list_type
      when :list_with_children
        Lists::ListWithChildren
      when :list_without_children
        Lists::ListWithoutChildren
      end
    end
  end
end
