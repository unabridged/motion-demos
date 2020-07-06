class ClickerGame < ApplicationRecord
  has_many :clicker_players, dependent: :destroy

  validates :key, presence: true, uniqueness: true

  before_validation :set_key, on: :create

  private

  def generate_unique_key
    loop do
      key = SecureRandom.hex(5)
      break key unless self.class.where(key: key).exists?
    end
  end

  def set_key
    self.key ||= generate_unique_key
  end
end
