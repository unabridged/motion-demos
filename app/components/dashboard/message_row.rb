module Dashboard
  class MessageRow < ViewComponent::Base
    include Motion::Component
    DATE_FORMAT = "%m/%d/%Y %I:%M:%S%p"
    attr_reader :user, :message

    delegate :content, :from, :to, :read?, to: :message

    map_motion :toggle_read
    map_motion :trash

    def initialize(user:, message:)
      @user = user
      @message = message
    end

    def toggle_read(event)
      new_status = read? ? :unread : :read
      id = message.id
      message.update(status: new_status)
      # ActionCable.server.broadcast("messages:read:#{id}", {id: id, status: new_status})
    end

    def trash(event)
      message.destroy
      # ActionCable.server.broadcast("messages:delete:#{message.id}", {id: message.id})
    end

    def sent_at
      message.created_at.strftime(DATE_FORMAT)
    end

    def from_display
      return from.name if read?

      content_tag(:strong, from.name)
    end

    def to_display
      return to.name if read?

      content_tag(:strong, to.name)
    end

    def row_class_names
      return nil unless read?

      "table-secondary"
    end
  end
end
