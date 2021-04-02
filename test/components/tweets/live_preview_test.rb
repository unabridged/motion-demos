# frozen_string_literal: true

require "test_helper"

module Tweets
  class LivePreviewTest < ViewComponent::TestCase
    include Motion::TestHelpers

    let(:klass) { Tweets::LivePreview }
    let(:content) { "My First Tweet" }
    let(:tweet) { Tweet.new }
    let(:feed) { [] }
    subject { klass.new(tweet: tweet, feed: feed) }

    describe "rendering" do
      before do
        render_inline(subject)
      end

      it "shows preview and feed" do
        assert_selector ".live-preview" do
          assert_selector "#preview"
          assert_selector "#feed"
        end
      end

      describe "when tweet content is present" do
        let(:tweet) { Tweet.new(content: "Tweet") }

        it "shows form and preview" do
          assert_selector "#preview" do
            assert_selector ".tweet", { count: 1, text: "Tweet" }
            assert_selector "form[data-motion-key]"
          end
        end
      end

      describe "when tweet content is not present" do
        it "shows form but no preview" do
          assert_selector "#preview" do
            refute_selector ".tweet", { count: 1, text: "Tweet" }
            assert_selector "form[data-motion-key]"
          end
        end
      end

      describe "when feed empty" do
        it "shows feed but no tweets" do
          assert_selector "#feed" do
            refute_selector ".tweet"
          end
        end
      end

      describe "when feed" do
        let(:feed) { Array.new(3) { Tweet.new(content: "Tweet") } }

        it "shows feed" do
          assert_selector "#feed" do
            assert_selector ".tweet", { count: 3, text: "Tweet" }
          end
        end
      end
    end

    describe "#streams" do
      it { assert_timer subject, :update_tweet_stats, 5 }

      describe "#preview" do
        let(:preview) { -> { process_broadcast(subject, :preview, attrs) } }
        let(:attrs) { { content: "My New Tweet" } }

        describe "when it updates attrs" do
          it "updates the tweet attrs" do
            preview.call
            assert_equal attrs[:content], tweet.content
          end
        end

        describe "when it updates id" do
          let(:attrs) { { id: 5 } }

          it "updates the id on the tweet" do
            preview.call
            assert_equal 5, tweet.id
          end

          it "adds the tweet to the feed" do
            assert_difference "subject.feed.count" do
              preview.call
            end
          end

          it "creates a new tweet for the form" do
            preview.call
            refute_equal tweet.object_id, subject.tweet.object_id
          end
        end
      end

      # NOTE: #update_tweet_stats is mocked, so the test is for currently functionality, ie - a mock
      describe "#update_tweet_stats" do
        let(:feed) { Array.new(3) { |i| Tweet.new(hearts: i, retweets: i) } }
        let(:hearts_retweets) { -> { feed.map { |tw| "#{tw.hearts}-#{tw.retweets}" }.join } }
        let(:hearts) { feed.map(&:he) }
        let(:preview) { -> { process_broadcast(subject, :update_tweet_stats, attrs) } }
        let(:attrs) { { id: 1, content: "My New Tweet" } }

        describe "when there is a feed" do
          it "updates the attrs of a tweet" do
            assert_changes hearts_retweets do
              process_broadcast(subject, :update_tweet_stats, attrs)
            end
          end
        end

        describe "when there is no feed" do
          let(:feed) { [] }
          it "does nothing" do
            assert_no_changes hearts_retweets do
              process_broadcast(subject, :update_tweet_stats, attrs)
            end
          end
        end
      end
    end
  end
end
