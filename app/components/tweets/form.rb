module Tweets
  class Form < ViewComponent::Base
    include Motion::Component

    attr_reader :tweet, :on_change
    map_motion :validate
    map_motion :save

    def initialize(tweet: Tweet.new(user: current_user), on_change:)
      @tweet = tweet
      @on_change = on_change
    end

    def validate(event)
      puts "validate"
      attrs = tweet_attributes(event.form_data)
      tweet.assign_attributes(attrs)
      on_change.call(attrs)
    end

    def save
      on_change.call({id: 1})
    end

    def disabled?
      tweet.content.blank?
    end

    private

    def tweet_attributes(params)
      params
        .require(:tweet)
        .permit(:content)
    end
  end
end
