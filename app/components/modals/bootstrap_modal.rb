module Modals
  class BootstrapModal < ViewComponent::Base
    include Motion::Component

    attr_reader :selected, :content
    map_motion :dismiss

    def initialize(selected:, show_trigger:, modal_channel:, content:)
      @selected = selected
      @show_trigger = show_trigger
      @modal_channel = modal_channel
      @content = content
    end

    def show_button?
      selected && @show_trigger
    end

    def dismiss(event)
      # Unless you check that the thing they clicked to dismiss
      # was also something that bootstrap uses to dismiss,
      # you can trigger inconsistent state:
      # 1. Broadcast below sent
      # 2. Parent component responds to the broadcast by changing its state
      # 3. Parent component will re-render
      # 4. The modal will be 'open' without appearing open
      #
      # So make sure you either:
      # a. do not change parent state from a child while modal is open
      # b. only change parent state when modal is going to close
      return unless event.target.data["value"] == "dismissable"

      broadcast_user_dismissed_modal
    end

    private

    def broadcast_user_dismissed_modal
      ActionCable.server.broadcast(@modal_channel, {event: "dismiss-modal"})
    end
  end
end
