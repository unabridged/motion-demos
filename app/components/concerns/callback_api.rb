require "active_support/concern"

module CallbackApi
  extend ActiveSupport::Concern

  class Callback
    attr_reader :broadcast
    def initialize(component, method)
      @broadcast = "motion:broadcast:#{component.callback_channel}:#{method}"

      # TODO: investigate why this doesn't seem to be working locally
      # Complicated example, or never works?
      component.stream_from(broadcast, method)
    end

    def call(msg = {})
      ActionCable.server.broadcast(broadcast, msg)
    end
  end

  def callback_channel
    @callback_channel ||= SecureRandom.uuid
  end

  def bind(method)
    Callback.new(self, method)
  end
end
