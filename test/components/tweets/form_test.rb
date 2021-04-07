# frozen_string_literal: true

require "test_helper"
require "view_component/test_case"

module Tweets
  class FormTest < ViewComponent::TestCase
    include Motion::TestHelpers
    let(:klass) { Tweets::Form }
    let(:tweet) { Tweet.new }
    let(:on_change) { callback_stub }
    let(:new_tweet) { false }
    subject { klass.new(tweet: tweet, on_change: on_change, new_tweet: new_tweet) }

    describe "rendering" do
      it "shows form with textarea and submit button" do
        render_inline(subject)
        assert_selector "form" do
          assert_selector "textarea"
          assert_selector "input[type='submit']"
        end
      end

      describe "when !disabled?" do
        let(:tweet) { Tweet.new(content: "tweet") }
        before do
          refute subject.disabled?
          render_inline(subject)
        end

        it "submit is not disabled" do
          refute_selector "input[type='submit'][disabled]"
        end
      end

      describe "when disabled?" do
        before do
          assert subject.disabled?
          render_inline(subject)
        end

        it "submit is disabled" do
          assert_selector "input[type='submit'][disabled]"
        end
      end
    end

    describe "motions" do
      it { assert_motion subject, :validate }
      it { assert_motion subject, :save }

      describe "#validate" do
        let(:attrs) { {content: "new tweet"} }
        let(:event) { motion_form_event(element: {formData: {tweet: attrs}}) }

        it "calls on change with attrs" do
          subject.on_change.expects(:call).with(broadcast_msg(attrs))
          run_motion subject, :validate, event
        end
      end

      describe "#save" do
        describe "when disabled" do
          before { subject.stubs(disabled?: true) }

          it "does not call on_change" do
            subject.on_change.expects(:call).never
            run_motion subject, :save, nil
          end
        end

        describe "when not disabled" do
          before { subject.stubs(disabled?: false) }

          it "calls on change" do
            subject.on_change.expects(:call).with({id: 1})
            run_motion subject, :save
          end
        end
      end
    end

    describe "#disabled?" do
      describe "when invalid" do
        before { tweet.stubs(valid?: false) }
        it { assert subject.disabled? }
      end

      describe "when valid" do
        before { tweet.stubs(valid?: true) }
        it { refute subject.disabled? }
      end
    end

    def broadcast_msg(attrs)
      ActiveSupport::JSON.decode(attrs.to_json)
    end

    def motion_form_event(attrs = {})
      event = Motion::Event.new(broadcast_msg(attrs))
      form_data = attrs.dig(:element, :formData) || {}
      params = ActionController::Parameters.new(form_data)
      event.element.instance_variable_set("@form_data", params)
      event
    end
  end
end
