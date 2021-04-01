# frozen_string_literal: true

require "test_helper"

module Tweets
  class DisplayTest < ViewComponent::TestCase
    include Motion::TestHelpers
    include ActionDispatch::Assertions::SelectorAssertions

    let(:klass) { Tweets::Display }
    let(:tweet) { Tweet.new }
    subject { klass.new(tweet: tweet) }

    describe "rendering" do
      before do
        @response_from_page = render_inline(subject).to_html
      end

      it "shows username, svg, and full name in header" do
        @response_from_page = render_inline(subject).to_html

        assert_select ".tweet-header" do
          assert_select ".tweet-fullname", { count: 1, text: "User Full Name" }
          assert_select ".tweet-username", { count: 1, text: "@username" }
          assert_select "svg", 1
        end
      end
    end

    # assert_select needs response_from_page
    def response_from_page
      @response_from_page
    end
  end
end
