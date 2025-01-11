class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :password, presence: true, length: { minimum: 10, maximum: 16 }

  normalizes :name, with: ->(value) { value.strip }
end
