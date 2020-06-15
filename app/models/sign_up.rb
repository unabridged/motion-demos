class SignUp
  include ActiveModel::Model

  attr_accessor :name, :email, :favorite_color, :birthday, :plan, :accept, :comments

  validates :name, presence: true
  validates :email, presence: true
  validates :favorite_color, inclusion: { in: [:pink, :yellow] }
  validates :birthday, presence: true
  validates :plan, inclusion: { in: [1, 2] }
  validates :accept, presence: true
  validates :comments, length: { minimum: 10 }
end
