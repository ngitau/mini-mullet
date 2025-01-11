class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :password, presence: true, length: { minimum: 10, maximum: 16 }
  validates_with PasswordComplexityValidator

  normalizes :name, with: ->(value) { value.strip }
end
