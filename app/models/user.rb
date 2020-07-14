class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  enum status: [:offline, :online, :busy]

  has_many :messages, -> { active }, foreign_key: :to_id
  has_many :deleted_messages, -> { deleeted }, foreign_key: :to_id, class_name: "Message"
  has_many :sent_messages, -> { active_sent }, foreign_key: :from_id, class_name: "Message"
  has_many :deleted_sent_messages, -> { deleted_sent }, foreign_key: :from_id, class_name: "Message"

  after_update :broadcast_update

  def starred_messages
    Message.starred_by_user(self)
  end

  private

  def broadcast_update
    ActionCable.server.broadcast("users:update:#{id}", {id: id})
  end
end
