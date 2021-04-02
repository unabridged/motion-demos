# frozen_string_literal: true

module Modals
  # Parent for modal demo
  class ModalDemo < ViewComponent::Base
    include Motion::Component
    delegate :numbers_to_words, to: :helpers
    attr_reader :selected, :modal_mode

    description = <<~STR
      Buttons will also reset selected state, but if user hits escape key, you cannot guarantee the state of selected goes back to nil.
    STR
    modal_trigger_description = <<~STR
      Buttons will also reset selected state, but if user hits escape key, you cannot guarantee the state of selected goes back to nil.
      Use if buttons to select also reset parent state.
    STR
    motion_description = <<~STR
      Buttons should work to dismiss the modal, but the escape key will not, and focus is not captured.
    STR
    CONTENT_DESCRIPTION = {
      modal: description,
      modal_with_trigger: modal_trigger_description,
      motion: motion_description
    }.freeze

    map_motion :selection
    map_motion :mode

    def initialize
      @selected = nil
      @modal_mode = :motion
    end

    def body
      CONTENT_DESCRIPTION[modal_mode]
    end

    def open_motion_modal?
      modal_mode == :motion && selected.present?
    end

    def show_bootstrap_trigger?
      modal_mode == :modal_with_trigger
    end

    def selection(event)
      @selected = event.target.data["value"]
    end

    def mode(event)
      @modal_mode = event.target.data["value"].to_sym
    end

    def dismiss(_msg)
      @selected = nil
    end

    def modal_channel
      @modal_channel ||= SecureRandom.uuid
    end
  end
end
