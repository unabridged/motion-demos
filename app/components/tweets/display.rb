module Tweets
  class Display < ViewComponent::Base
    # This component does not need Motion, it is only for displaying
    attr_reader :tweet
    delegate :hearts, :retweets, to: :tweet

    def initialize(tweet: Tweet.new)
      @tweet = tweet
    end

    def tweet_status
      tweet.id.present? ? "sent" : "draft"
    end

    def tweeted_at
      tweet.tweeted_at.strftime("%I:%M %p %b %d, %Y")
    end
  end
end
