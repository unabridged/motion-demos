class SignUp
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :favorite_color, :string
  attribute :plan, :integer
  attribute :accept, :boolean
  attribute :birthday, :date
  attribute :comments, :string

  validates :name, presence: true
  validates :email, presence: true
  validates :favorite_color, inclusion: { in: %w(pink yellow) }
  validates :birthday, presence: true
  validates :plan, inclusion: { in: [1, 2] }
  validates :accept, acceptance: true
  validates :comments, length: { minimum: 10 }
end
