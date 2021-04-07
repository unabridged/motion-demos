# frozen_string_literal: true

require "test_helper"

module Tweets
  class DisplayTest < ViewComponent::TestCase
    include Motion::TestHelpers

    let(:klass) { Tweets::Display }
    let(:content) { "My First Tweet" }
    let(:tweet) { Tweet.new(content: content) }
    subject { klass.new(tweet: tweet) }

    describe "rendering" do
      before do
        render_inline(subject)
      end

      it "shows username, svg, and full name in header" do
        assert_selector ".tweet-header" do
          assert_selector ".tweet-fullname", {count: 1, text: "User Full Name"}
          assert_selector ".tweet-username", {count: 1, text: "@username"}
          assert_selector "svg"
        end
      end

      it "shows content and time in body" do
        assert_selector ".tweet-body" do
          assert_selector ".tweet-content", {count: 1, text: content}
          assert_selector ".tweet-time"
        end
      end

      it "shows hearts and retweets in footer" do
        assert_selector ".tweet-footer" do
          assert_selector ".link-heart"
          assert_selector ".link-retweet"
        end
      end
    end
  end
end
