module Lists
  class Sibling < ViewComponent::Base
    include Motion::Component

    attr_reader :channel

    def initialize(channel:)
      @channel = channel
      stream_from channel, :list_length
    end

    ## Map Motion
    def list_length(msg)
      @length = msg["length"] if msg["length"]
      @count = msg["count"] if msg["count"]
    end
    ## end map motion
  end
end
