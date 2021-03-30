module Tweets
  class LivePreview < ViewComponent::Base
    include Motion::Component

    attr_reader :tweet, :feed

    def initialize(tweet: Tweet.new, feed: [])
      @tweet = tweet
      @feed = feed
    end

    def preview(attrs)
      tweet.assign_attributes(attrs.merge(tweeted_at: Time.current))
      new_tweet if tweet.id.present?
    end

    private

    def new_tweet
      feed.unshift(tweet)
      @tweet = Tweet.new
    end

    # Mock getting an update from a tweet in the feed
    # For a saved record, you would listen for broadcasts, instead of ticking
    every 5.seconds, :update_tweet_stats

    def update_tweet_stats(msg = {})
      updated = find_tweet(msg)
      return unless updated.present?

      update_stat(updated, msg)
    end

    # Mock method to find a tweet from a message
    def find_tweet(_msg)
      feed.sample
    end

    # Mock method to update a tweet using a msg
    def update_stat(tweet, _msg)
      update = %i(hearts retweets).sample
      tweet.increment(update)
    end
  end
end
