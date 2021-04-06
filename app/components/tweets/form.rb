module Tweets
  class Form < ViewComponent::Base
    include Motion::Component
    delegate :validation_messages, :valid_class, to: :helpers

    attr_reader :tweet, :on_change, :new_tweet
    map_motion :validate
    map_motion :save

    def initialize(tweet:, on_change:, new_tweet:)
      @tweet = tweet
      @on_change = on_change
      @new_tweet = new_tweet
      tweet.validate unless new_tweet
    end

    def validate(event)
      attrs = tweet_attributes(event.form_data)
      on_change.call(attrs)
    end

    def save
      return if disabled?

      # Mock calling save
      on_change.call({id: 1})
    end

    def disabled?
      !tweet.valid?
    end

    private

    def tweet_attributes(params)
      params
        .require(:tweet)
        .permit(:content)
    end
  end
end
