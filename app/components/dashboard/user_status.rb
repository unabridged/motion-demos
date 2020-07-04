module Dashboard
  class UserStatus < ViewComponent::Base
    include Motion::Component
    attr_reader :user
    delegate :status, to: :user

    def initialize(user:)
      @user = user

      stream_from user_channel, :update_user
    end

    def status_icon
      case status
      when :offline
        "text-warning"
      when :busy
        "text-success"
      when :online
        "text-info"
      end
    end

    def user_channel
      "users:updated:#{user.id}"
    end

    def update_user(msg)
      u = User.find_by(id: msg["id"])

      @user = u if u.present?
    end
  end
end
