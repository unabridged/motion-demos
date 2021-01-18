# frozen_string_literal: true

require "test_helper"

module Modals
  class MotionModalTest < ViewComponent::TestCase
    include Motion::TestHelpers
    let(:klass) { Modals::MotionModal }
    let(:on_dismiss) { callback_stub }
    let(:selected) { 1 }
    let(:content) { "some content" }

    subject { klass.new(selected: selected, on_dismiss: on_dismiss, content: content) }

    describe "#initialize" do
      it "sets show to false" do
        refute subject.modal_show_class
      end

      it "creates periodic timer to call fade_out" do
        handler = :fade_in
        interval = 0.1.seconds
        assert_equal interval, subject.periodic_timers[handler.to_s]
      end
    end

    describe "rendering" do
      it "renders as a motion component" do
        result = render_inline(subject).to_html
        assert_match(/data-motion-key=/, result)
      end

      it "renders modal" do
        result = render_inline(subject).to_html

        assert_match(/class="modal-open"/, result)
        assert_match(/class="modal fade/, result)
      end
    end

    describe "motions" do
      describe "#dismiss" do
        let(:selected_value) { "dismissable" }
        let(:params) { {target: {attributes: {"data-value" => selected_value}}} }
        let(:event) { motion_event(params) }

        describe "when dismissable event" do
          let(:selected_value) { "dismissable" }

          it "sets show to false" do
            subject.instance_variable_set("@show", true)
            run_motion(subject, :dismiss, event)
            refute subject.show
          end

          it "creates periodic timer to call fade_out" do
            handler = :fade_out
            interval = 0.1.seconds
            run_motion(subject, :dismiss, event)
            assert_equal interval, subject.periodic_timers[handler.to_s]
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

    describe "timers" do
      describe "#fade_in" do
        it "sets show to true" do
          refute subject.show

          subject.fade_in

          assert subject.show
        end

        it "removes periodic timer for itself" do
          assert subject.periodic_timers[:fade_in.to_s]
          assert_changes -> { subject.periodic_timers[:fade_in.to_s] } do
            subject.fade_in
          end
        end
      end

      describe "#fade_out" do
        it "calls on_dismiss" do
          on_dismiss.expects(:call)
          subject.fade_out
        end

        it "removes periodic timer for itself" do
          subject.every 1.second, :fade_out
          assert_changes -> { subject.periodic_timers[:fade_out.to_s] } do
            subject.fade_out
          end
        end
      end
    end

    describe "#modal_show_class?" do
      describe "when show" do
        before { subject.instance_variable_set("@show", true) }
        it { assert subject.modal_show_class }
      end

      describe "when not show" do
        before { subject.instance_variable_set("@show", false) }
        it { refute subject.modal_show_class }
      end
    end
  end
end
