class Message < ApplicationRecord
  belongs_to :from, class_name: "User"
  belongs_to :to, class_name: "User"

  enum status: [:unread, :read, :archived]

  validates :from, presence: true
  validates :to, presence: true
  validates :content, presence: true

  after_create :broadcast_create
  after_update :broadcast_read
  after_commit :broadcast_delete, on: :destroy

  scope :paginated, ->(offset = 0, limit = 20) { order(:created_at).offset(offset * limit).limit(limit) }

  def today?
    created_at.today?
  end

  private

  def broadcast_create
    ActionCable.server.broadcast("messages:from:#{from_id}", {id: id})
    ActionCable.server.broadcast("messages:to:#{to_id}", {id: id})
  end

  def broadcast_read
    ActionCable.server.broadcast("messages:read:#{id}", {id: id, status: status})
  end

  def broadcast_delete
    ActionCable.server.broadcast("messages:delete:#{id}", {id: id})
  end
end
