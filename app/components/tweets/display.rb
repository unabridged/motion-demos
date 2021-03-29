module Tweets
  class Display < ViewComponent::Base
    attr_reader :tweet

    def initialize(tweet: Tweet.new(user: current_user))
      @tweet = tweet
    end
  end
end
