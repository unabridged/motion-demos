# frozen_string_literal: true

require "test_helper"

module Modals
  class ModalDemoTest < ViewComponent::TestCase
    include Motion::TestHelpers
    let(:klass) { Modals::ModalDemo }

    subject { klass.new }

    describe "rendering" do
      it "shows 3 sections for mode, selection, and current state" do
        result = render_inline(subject).to_html

        assert_match("Select a way to trigger the modal", result)
        assert_match("Select a number to display inside the modal", result)
        assert_match("Current state ", result)
      end

      it "renders as a motion component plus another motion component" do
        result = render_inline(subject).to_html
        assert_equal 3, result.split("data-motion-key=").length
      end

      describe "when open_motion_modal? is true" do
        before { subject.instance_variable_set("@selected", "1") }
        it "renders two other motion components" do
          assert subject.open_motion_modal?
          result = render_inline(subject).to_html
          assert_equal 4, result.split("data-motion-key=").length
        end
      end
    end

    describe "motions" do
      describe "#selection" do
        let(:selected_value) { "new_value" }
        let(:params) { {target: {attributes: {"data-value" => selected_value}}} }
        let(:event) { motion_event(params) }

        it "updates selected" do
          assert_nil subject.selected

          run_motion(subject, :selection, event)

          assert_equal selected_value, subject.selected
        end
      end

      describe "#mode" do
        let(:mode) { "new_mode" }
        let(:params) { {target: {attributes: {"data-value" => mode}}} }
        let(:event) { motion_event(params) }

        it "updates selected" do
          assert_equal :motion, subject.modal_mode

          run_motion(subject, :mode, event)

          assert_equal mode.to_sym, subject.modal_mode
        end
      end
    end

    describe "stream_events" do
      describe "#dismiss" do
        let(:selected) { "selected" }
        let(:params) { {target: {value: selected_value}} }
        let(:event) { motion_event(params) }

        it "resets selected" do
          subject.instance_variable_set("@selected", selected)
          assert_equal selected, subject.selected

          process_broadcast(subject, :dismiss, {})

          assert_nil subject.selected
        end
      end
    end

    describe "#show_bootstrap_trigger?" do
      let(:modal_with_trigger_mode) { :modal_with_trigger }
      let(:non_trigger_mode) { klass::CONTENT_DESCRIPTION.keys.reject { |cd| cd == modal_with_trigger_mode }.sample }

      describe "when modal_mode is modal_with_trigger_mode" do
        before { subject.instance_variable_set("@modal_mode", modal_with_trigger_mode) }
        it { assert subject.show_bootstrap_trigger? }
      end

      describe "when modal_mode is not modal_with_trigger_mode" do
        before { subject.instance_variable_set("@modal_mode", non_trigger_mode) }
        it { refute subject.show_bootstrap_trigger? }
      end
    end

    describe "#open_motion_modal?" do
      let(:motion_mode) { :motion }
      let(:non_motion_mode) { klass::CONTENT_DESCRIPTION.keys.reject { |cd| cd == motion_mode }.sample }

      describe "when modal_mode is modal" do
        before { subject.instance_variable_set("@modal_mode", motion_mode) }
        describe "when selected is present" do
          before { subject.instance_variable_set("@selected", true) }
          it { assert subject.open_motion_modal? }
        end

        describe "when selected is not present" do
          before { subject.instance_variable_set("@selected", false) }
          it { refute subject.open_motion_modal? }
        end
      end

      describe "when modal_mode is not modal" do
        before do
          subject.instance_variable_set("@selected", [true, false].sample)
          subject.instance_variable_set("@modal_mode", non_motion_mode)
        end
        it { refute subject.open_motion_modal? }
      end
    end
  end
end
