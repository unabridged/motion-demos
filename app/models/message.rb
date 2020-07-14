class Message < ApplicationRecord
  belongs_to :from, class_name: "User"
  belongs_to :to, class_name: "User"

  enum status: [:unread, :read, :archived]

  validates :from_id, presence: true
  validates :to_id, presence: true
  validates :content, presence: true

  after_create :broadcast_create
  after_update :broadcast_update
  after_commit :broadcast_delete, on: :destroy

  scope :paginated, ->(offset = 0, limit = 20) { order(created_at: :desc).offset(offset * limit).limit(limit) }
  scope :active, -> { where(deleted_by_to: nil) }
  scope :active_sent, -> { where(deleted_by_from: nil) }
  scope :deleted, -> { where.not(id: active) }
  scope :deleted_sent, -> { where.not(id: active_sent) }
  scope :starred_by_user, ->(user) { user.messages.where.not(starred_by_to: nil).or(user.sent_messages.where.not(starred_by_from: nil)) }

  def from?(user)
    user == from
  end

  def to?(user)
    user == to
  end

  def mark_read!
    update!(status: :read)
  end

  def star!(user)
    return false unless belongs_to_user?(user)
    return update!(starred_by_to: Time.current) if user == to

    update!(starred_by_from: Time.current)
  end

  def unstar!(user)
    return false unless belongs_to_user?(user)
    return update!(starred_by_to: nil) if user == to

    update!(starred_by_from: nil)
  end

  def delete!(user)
    return false unless belongs_to_user?(user)
    return update!(deleted_by_to: Time.current) if user == to

    update!(deleted_by_from: Time.current)
  end

  def deleted?(user)
    return false unless belongs_to_user?(user)
    return deleted_by_to.present? if user == to

    deleted_by_from.present?
  end

  def starred?(user)
    return false unless belongs_to_user?(user)
    return starred_by_to.present? if user == to

    starred_by_from.present?
  end

  def belongs_to_user?(user)
    to == user || from == user
  end

  private

  def broadcast_create
    ActionCable.server.broadcast("messages:from:#{from_id}", {id: id})
    ActionCable.server.broadcast("messages:to:#{to_id}", {id: id})
    ActionCable.server.broadcast("messages:create", {id: id})
  end

  def broadcast_update
    ActionCable.server.broadcast("messages:from:#{from_id}", {id: id})
    ActionCable.server.broadcast("messages:to:#{to_id}", {id: id})
    ActionCable.server.broadcast("messages:update:#{id}", {id: id, status: status})
  end

  def broadcast_delete
    ActionCable.server.broadcast("messages:from:#{from_id}", {id: id})
    ActionCable.server.broadcast("messages:to:#{to_id}", {id: id})
    ActionCable.server.broadcast("messages:delete:#{id}", {id: id})
  end
end
