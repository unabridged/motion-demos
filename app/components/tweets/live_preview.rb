module Tweets
  class LivePreview < ViewComponent::Base
    include Motion::Component

    attr_reader :tweet

    def initialize(tweet: Tweet.new)
      @tweet = tweet
    end

    def preview(attrs)
      tweet.assign_attributes(attrs)
    end

    def saved?
      tweet.id.present?
    end
  end
end
