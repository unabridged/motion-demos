module Tweets
  class Form < ViewComponent::Base
    include Motion::Component
    delegate :validation_messages, :valid_class, to: :helpers

    attr_reader :tweet, :on_change
    map_motion :validate
    map_motion :save

    def initialize(tweet:, on_change:)
      @tweet = tweet
      tweet.validate
      @on_change = on_change
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
