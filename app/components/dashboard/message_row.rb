module Dashboard
  class MessageRow < ViewComponent::Base
    include Motion::Component
    include SvgHelper
    attr_reader :user, :message

    delegate :content, :from, :to, :read?, :starred?, :display_sent_at, to: :message

    map_motion :read_msg
    map_motion :star
    map_motion :trash

    def initialize(user:, message:, row:, on_click:)
      @user = user
      @message = message
      @row = row
      @on_click = on_click
    end

    ## Map motions
    def read_msg
      @on_click.call({id: message.id})
    end

    def trash
      message.delete!(user)
    end

    def star
      return message.star!(user) unless starred?(user)

      message.unstar!(user)
    end
    ## End map motions

    def display_star
      return "star-fill" if starred?(user)

      "star"
    end

    def display_status_user
      sent_to_user? ? from : to
    end

    def display_name
      return display_name_for_name("From: ", from_display) if sent_to_user?

      display_name_for_name("To: ", to_display)
    end

    def row_class_names
      return nil unless read? && sent_to_user?

      "table-dark"
    end

    private

    def sent_to_user?
      to == user
    end

    def display_name_for_name(display_text, display_name)
      content_tag :span do
        content_tag(:span, display_text) +
          display_name
      end
    end

    def from_display
      return from.name if read?

      content_tag(:strong, from.name)
    end

    def to_display
      return to.name if read?

      content_tag(:strong, to.name)
    end
  end
end
