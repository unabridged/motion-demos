class SignUp
  include ActiveModel::Model
  include ActiveModel::Attributes

  COLORS = %w(pink yellow)

  attribute :name, :string
  attribute :email, :string
  attribute :favorite_color, :string
  attribute :plan, :integer
  attribute :terms, :boolean
  attribute :birthday, :date
  attribute :comments, :string

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :favorite_color, inclusion: { in: COLORS, message: "must be #{COLORS.to_sentence(two_words_connector: " or ", last_word_connector: " or ")}" }
  validates :birthday, presence: true
  validates :plan, inclusion: { in: [1, 2], message: "is unavailable" }
  validates :terms, acceptance: true
  validates :comments, length: { minimum: 10 }
end
