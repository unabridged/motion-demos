class Tweet
  # No need for db in this example, but ActiveModel is useful
  include ActiveModel::Model

  attr_accessor :content, :id
  attr_writer :tweeted_at, :hearts, :retweets

  validates_length_of :content, maximum: 280, allow_blank: false

  # Set sensible defaults, unbacked by db
  def username
    "@username"
  end

  def full_name
    "User Full Name"
  end

  def tweeted_at
    @tweeted_at ||= Time.current
  end

  def hearts
    @hearts ||= 0
  end

  def retweets
    @retweets ||= 0
  end

  def increment(method_name, by_value = 1)
    send("#{method_name}=", send(method_name) + by_value)
  end
end
