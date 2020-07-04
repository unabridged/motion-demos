class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  enum status: [:offline, :online, :busy]

  has_many :messages, foreign_key: :to_id
  has_many :sent_messages, foreign_key: :from_id, class_name: "Message"

  after_update :broadcast_update

  private

  def broadcast_update
    ActionCable.server.broadcast("users:update:#{id}", {id: id})
  end
end
