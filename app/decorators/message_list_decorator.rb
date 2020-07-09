class MessageListDecorator
  def perform(messages)
    messages.map { |msg| MessageDecorator.new(msg) }
  end
end
