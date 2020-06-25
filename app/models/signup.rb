class Signup < ApplicationRecord
  COLORS = %w(pink yellow)

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :favorite_color, inclusion: { in: COLORS, message: "must be #{COLORS.to_sentence(two_words_connector: " or ", last_word_connector: " or ")}" }
  validates :birthday, presence: true
  validates :plan, inclusion: { in: [1, 2], message: "is unavailable" }
  validates :terms, acceptance: true
  validates :comments, length: { minimum: 10 }
  validates :country, presence: true
  validates :state, presence: true

  before_save :clear_state

  def clear_state
    if country_changed? && !country_was.nil?
      self.state = nil
    end
  end
end
