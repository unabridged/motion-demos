# frozen_string_literal: true

require "test_helper"

module Modals
  class BootstrapModalTest < ViewComponent::TestCase
    include Motion::TestHelpers
    let(:klass) { Modals::BootstrapModal }
    let(:on_dismiss) { callback_stub }
    let(:selected) { 1 }
    let(:show) { true }
    let(:content) { "Some content" }

    subject { klass.new(selected: selected, show_trigger: show, on_dismiss: on_dismiss, content: content) }

    describe "rendering" do
      it "renders as a motion component" do
        result = render_inline(subject).to_html
        assert_match(/data-motion-key=/, result)
      end

      describe "when show is true" do
        let(:show) { true }
        it "renders modal plus trigger" do
          result = render_inline(subject).to_html

          assert_match(/class="modal fade"/, result)
          assert_match(/id="exampleModalLabel"/, result)
          assert_match(/data-target="#exampleModal"/, result)
        end
      end

      describe "when show is false" do
        let(:show) { false }
        it "renders modal plus trigger" do
          result = render_inline(subject).to_html

          assert_match(/class="modal fade"/, result)
          assert_match(/id="exampleModalLabel"/, result)
          assert_no_match(/data-target="#exampleModal"/, result)
        end
      end
    end

    describe "motions" do
      describe "#dismiss" do
        let(:selected_value) { "dismissable" }
        let(:params) { {target: {attributes: {"data-value" => selected_value}}} }
        let(:event) { motion_event(params) }

        describe "when dismissable event" do
          let(:selected_value) { "dismissable" }

          it "calls on_dismiss" do
            on_dismiss.expects(:call)
            run_motion(subject, :dismiss, event)
          end
        end

        describe "when other event" do
          let(:selected_value) { "other" }
          it "does not call on_dismiss" do
            on_dismiss.expects(:call).never
            run_motion(subject, :dismiss, event)
          end
        end
      end
    end

    describe "#show_button?" do
      describe "when selected and show" do
        let(:selected) { "1" }
        let(:show) { true }
        it { assert subject.show_button? }
      end

      describe "when selected and show" do
        let(:selected) { [true, false].sample }
        let(:show) { !selected }
        it { refute subject.show_button? }
      end
    end
  end
end
