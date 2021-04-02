# frozen_string_literal: true

module Modals
  # Modal controlled by motion
  class MotionModal < ViewComponent::Base
    include Motion::Component

    attr_reader :selected, :content, :show

    map_motion :dismiss

    def initialize(on_dismiss:, selected:, content:)
      @on_dismiss = on_dismiss
      @selected = selected
      @content = content
      @show = false

      every 0.1.second, :fade_in
    end

    ## Periodic timers
    # The periodic timer allows the background to animate in and out
    # If you didn't care about the css animation, you could remove them and
    # broadcast in the `dismiss` method
    def fade_in
      @show = true

      stop_periodic_timer :fade_in
    end

    def fade_out
      # This actually closes the modal, 0.1s later
      @on_dismiss.call({event: "dismiss-modal"})

      stop_periodic_timer :fade_out
    end
    ## End Periodic timers

    ## Map motion events
    def dismiss(event)
      # Did they click inside the modal, or click a button or outside modal to close
      return unless event.target.data["value"] == "dismissable"

      @show = false

      every 0.1.second, :fade_out
    end
    ## End map motion events

    # This adds a class that bootstrap adds with JS and causes a css animation
    def modal_show_class
      show ? "show" : nil
    end

    # This adds style that bootstrap adds with JS
    def modal_style
      <<-STYLE
        display: block;
        background-color: rgba(0, 0, 0, 0.6);
      STYLE
    end
  end
end
